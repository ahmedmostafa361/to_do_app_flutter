// lib/core/services/speech_service.dart
import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart' as stt;

// ─────────────────────────────────────────────────────────────────────────────
// Voice states exposed to the UI layer
// ─────────────────────────────────────────────────────────────────────────────

enum VoiceState { idle, listening, processing }

// ─────────────────────────────────────────────────────────────────────────────
// Abstract contract
// ─────────────────────────────────────────────────────────────────────────────

abstract class SpeechService {
  Future<void> initialize();

  Future<String> startListening({String localeId});

  Future<void> stopListening();

  Future<void> cancelListening();

  bool get isListening;

  Stream<String> get transcriptionStream;

  VoiceState get voiceState;

  void dispose();
}

// ─────────────────────────────────────────────────────────────────────────────
// Production implementation
// ─────────────────────────────────────────────────────────────────────────────

class RealSpeechService implements SpeechService {
  // ── STT engine ──────────────────────────────────────────────
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _initialized = false;

  // ── State ────────────────────────────────────────────────────
  bool _isListening = false;
  VoiceState _voiceState = VoiceState.idle;

  // ── Completer that resolves with the final text ──────────────
  Completer<String>? _completer;

  // ── Real-time transcription stream ───────────────────────────
  final StreamController<String> _transcriptionController =
      StreamController<String>.broadcast();

  // ── Running transcription buffer ─────────────────────────────
  String _buffer = '';

  // ─────────────────────────────────────────────────────────────
  // Getters
  // ─────────────────────────────────────────────────────────────

  @override
  bool get isListening => _isListening;

  @override
  VoiceState get voiceState => _voiceState;

  @override
  Stream<String> get transcriptionStream => _transcriptionController.stream;

  // ─────────────────────────────────────────────────────────────
  // Initialize
  // ─────────────────────────────────────────────────────────────

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    _initialized = await _speech.initialize(
      onError: (error) {
        _isListening = false;
        _voiceState = VoiceState.idle;
        if (_completer != null && !_completer!.isCompleted) {
          _completer!.completeError(
            Exception('Speech error: ${error.errorMsg}'),
          );
        }
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
          _voiceState = VoiceState.idle;
          if (_completer != null && !_completer!.isCompleted) {
            final captured = _buffer.trim();
            if (captured.isNotEmpty) {
              _completer!.complete(captured);
            } else {
              _completer!.completeError(
                Exception('Nothing recognised. Please try again.'),
              );
            }
          }
        }
      },
      debugLogging: false,
    );

    if (!_initialized) {
      throw Exception(
        'Microphone permission denied or speech recognition not available.',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Locale helpers
  // ─────────────────────────────────────────────────────────────

  Future<List<stt.LocaleName>> _availableLocales() async {
    await initialize();
    return _speech.locales();
  }

  Future<String?> _resolveLocale(String langCode) async {
    final locales = await _availableLocales();
    final lower = langCode.toLowerCase();

    for (final l in locales) {
      if (l.localeId.toLowerCase() == lower) return l.localeId;
    }

    for (final l in locales) {
      final id = l.localeId.toLowerCase();
      if (id.startsWith(lower) || id.split('-')[0] == lower) {
        return l.localeId;
      }
    }

    return locales.isNotEmpty ? locales.first.localeId : null;
  }

  // ─────────────────────────────────────────────────────────────
  // startListening
  // ─────────────────────────────────────────────────────────────

  @override
  Future<String> startListening({String localeId = 'en'}) async {
    await initialize();

    if (_isListening) {
      await stopListening();
    }

    // Reset state parameters
    _buffer = '';
    _completer = Completer<String>();
    _voiceState = VoiceState.listening;
    _isListening = true;

    if (!_transcriptionController.isClosed) {
      _transcriptionController.add('');
    }

    final resolvedLocale = await _resolveLocale(localeId);

    await _speech.listen(
      onResult: (result) {
        if (result.recognizedWords.isEmpty) return;

        // Always sync the absolute, raw text buffer from the system engine
        _buffer = result.recognizedWords;

        // 🌟 FIXED: Emit the live string instantly without the artificial delay loop.
        // This stops weird random extra words from building up in your UI.
        if (!_transcriptionController.isClosed) {
          _transcriptionController.add(_buffer);
        }

        if (result.finalResult) {
          _isListening = false;
          _voiceState = VoiceState.idle;
          if (!_completer!.isCompleted) {
            _completer!.complete(_buffer.trim());
          }
        }
      },
      listenFor: const Duration(seconds: 60),
      // Keep dictation open up to a minute
      pauseFor: const Duration(seconds: 10),
      // Wait a full 10 seconds of pure silence
      localeId: resolvedLocale,
      cancelOnError: false,
      partialResults: true,
      listenMode: stt.ListenMode.dictation,
    );

    // 🌟 FIXED: Safety timeout must be longer than your listenFor window!
    // Increased to 65 seconds to prevent unexpected cutoff crashes.
    return _completer!.future.timeout(
      const Duration(seconds: 65),
      onTimeout: () {
        _isListening = false;
        _voiceState = VoiceState.idle;
        _speech.stop();
        final captured = _buffer.trim();
        if (captured.isNotEmpty) return captured;
        throw Exception('Listening timed out. Please try again.');
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // stopListening
  // ─────────────────────────────────────────────────────────────

  @override
  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
    _voiceState = VoiceState.idle;

    if (_completer != null && !_completer!.isCompleted) {
      final captured = _buffer.trim();
      if (captured.isNotEmpty) {
        _completer!.complete(captured);
      } else {
        _completer!.completeError(
          Exception('Nothing recognised. Please try again.'),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // cancelListening
  // ─────────────────────────────────────────────────────────────

  @override
  Future<void> cancelListening() async {
    await _speech.cancel();
    _isListening = false;
    _voiceState = VoiceState.idle;
    _buffer = '';

    if (!_transcriptionController.isClosed) {
      _transcriptionController.add('');
    }

    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError(Exception('cancelled'));
    }
  }

  // ─────────────────────────────────────────────────────────────
  // dispose
  // ─────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _transcriptionController.close();
  }
}
