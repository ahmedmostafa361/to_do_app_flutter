// lib/core/services/local_storage_service.dart
import '../../models/note_model.dart';

/// Simple in-memory storage for notes.
///
/// To swap to a real persistence layer (Hive, SQLite, SharedPreferences):
/// 1. Keep this same interface (saveNote / getAllNotes / updateNote / deleteNote)
/// 2. Replace only the method bodies
/// 3. NotesProvider needs zero changes
abstract class LocalStorageService {
  Future<void> saveNote(NoteModel note);

  Future<List<NoteModel>> getAllNotes();

  Future<void> updateNote(NoteModel updated);

  Future<void> deleteNote(String id);
}

// ─────────────────────────────────────────────────────────────────────────────

class InMemoryStorageService implements LocalStorageService {
  final List<NoteModel> _store = [];

  // ── Save ────────────────────────────────────────────────────

  @override
  Future<void> saveNote(NoteModel note) async {
    _store.add(note);
  }

  // ── Read ────────────────────────────────────────────────────

  @override
  Future<List<NoteModel>> getAllNotes() async {
    // Return newest-first so the list order is consistent with
    // the insert(0, ...) behaviour in NotesProvider.
    return _store.reversed.toList();
  }

  // ── Update ──────────────────────────────────────────────────

  @override
  Future<void> updateNote(NoteModel updated) async {
    final index = _store.indexWhere((n) => n.id == updated.id);
    if (index == -1) return;
    _store[index] = updated;
  }

  // ── Delete ──────────────────────────────────────────────────

  @override
  Future<void> deleteNote(String id) async {
    _store.removeWhere((n) => n.id == id);
  }
}

//
// // lib/core/services/speech_service.dart
// import 'dart:async';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Voice states exposed to the UI layer
// // ─────────────────────────────────────────────────────────────────────────────
//
// enum VoiceState { idle, listening, processing }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Abstract contract
// // ─────────────────────────────────────────────────────────────────────────────
//
// abstract class SpeechService {
//   /// One-time setup. Safe to call multiple times.
//   Future<void> initialize();
//
//   /// Start listening. Resolves with the final transcription when the user
//   /// stops speaking (natural pause) or [stopListening] is called.
//   ///
//   /// Emits partial results progressively through [transcriptionStream].
//   Future<String> startListening({String localeId});
//
//   /// Stop listening and resolve with whatever has been captured so far.
//   Future<void> stopListening();
//
//   /// Stop listening and discard all captured text.
//   Future<void> cancelListening();
//
//   /// Whether the microphone is currently active.
//   bool get isListening;
//
//   /// Live stream of partial transcription results.
//   /// Updates word-by-word as the user speaks.
//   Stream<String> get transcriptionStream;
//
//   /// Current voice engine state.
//   VoiceState get voiceState;
//
//   /// Must be called when the consumer widget is disposed.
//   void dispose();
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Production implementation
// // ─────────────────────────────────────────────────────────────────────────────
//
// class RealSpeechService implements SpeechService {
//   // ── STT engine ──────────────────────────────────────────────
//   final stt.SpeechToText _speech = stt.SpeechToText();
//   bool _initialized = false;
//
//   // ── State ────────────────────────────────────────────────────
//   bool _isListening = false;
//   VoiceState _voiceState = VoiceState.idle;
//
//   // ── Completer that resolves with the final text ──────────────
//   Completer<String>? _completer;
//
//   // ── Real-time transcription stream ───────────────────────────
//   final StreamController<String> _transcriptionController =
//   StreamController<String>.broadcast();
//
//   // ── Running transcription buffer ─────────────────────────────
//   String _buffer = '';
//
//   // ─────────────────────────────────────────────────────────────
//   // Getters
//   // ─────────────────────────────────────────────────────────────
//
//   @override
//   bool get isListening => _isListening;
//
//   @override
//   VoiceState get voiceState => _voiceState;
//
//   @override
//   Stream<String> get transcriptionStream => _transcriptionController.stream;
//
//   // ─────────────────────────────────────────────────────────────
//   // Initialize
//   // ─────────────────────────────────────────────────────────────
//
//   @override
//   Future<void> initialize() async {
//     if (_initialized) return;
//
//     _initialized = await _speech.initialize(
//       onError: (error) {
//         _isListening = false;
//         _voiceState = VoiceState.idle;
//         // Surface the error through the completer so the UI can react
//         if (_completer != null && !_completer!.isCompleted) {
//           _completer!.completeError(
//             Exception('Speech error: ${error.errorMsg}'),
//           );
//         }
//       },
//       onStatus: (status) {
//         // 'done' / 'notListening' means the engine finished on its own
//         if (status == 'done' || status == 'notListening') {
//           _isListening = false;
//           _voiceState = VoiceState.idle;
//           // Resolve with whatever we have buffered
//           if (_completer != null && !_completer!.isCompleted) {
//             final captured = _buffer.trim();
//             if (captured.isNotEmpty) {
//               _completer!.complete(captured);
//             } else {
//               _completer!.completeError(
//                 Exception('Nothing recognised. Please try again.'),
//               );
//             }
//           }
//         }
//       },
//       debugLogging: false,
//     );
//
//     if (!_initialized) {
//       throw Exception(
//         'Microphone permission denied or speech recognition not available.',
//       );
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────
//   // Locale helpers
//   // ─────────────────────────────────────────────────────────────
//
//   Future<List<stt.LocaleName>> _availableLocales() async {
//     await initialize();
//     return _speech.locales();
//   }
//
//   /// Finds the best locale for a given language code.
//   /// 'en' → 'en-US' or 'en-GB'; 'ar' → 'ar-SA' or 'ar-EG'.
//   Future<String?> _resolveLocale(String langCode) async {
//     final locales = await _availableLocales();
//     final lower = langCode.toLowerCase();
//
//     // 1. Exact match
//     for (final l in locales) {
//       if (l.localeId.toLowerCase() == lower) return l.localeId;
//     }
//
//     // 2. Prefix / base-language match
//     for (final l in locales) {
//       final id = l.localeId.toLowerCase();
//       if (id.startsWith(lower) || id.split('-')[0] == lower) {
//         return l.localeId;
//       }
//     }
//
//     // 3. Device default fallback
//     return locales.isNotEmpty ? locales.first.localeId : null;
//   }
//
//   // ─────────────────────────────────────────────────────────────
//   // startListening
//   // ─────────────────────────────────────────────────────────────
//
//   @override
//   Future<String> startListening({String localeId = 'en'}) async {
//     await initialize();
//
//     // Guard: if already listening, stop cleanly first
//     if (_isListening) {
//       await stopListening();
//     }
//
//     // Reset state
//     _buffer = '';
//     _completer = Completer<String>();
//     _voiceState = VoiceState.listening;
//     _isListening = true;
//
//     // Emit empty string so the UI clears any previous transcription
//     if (!_transcriptionController.isClosed) {
//       _transcriptionController.add('');
//     }
//
//     final resolvedLocale = await _resolveLocale(localeId);
//
//     await _speech.listen(
//       onResult: (result) {
//         if (result.recognizedWords.isEmpty) return;
//
//         // ── Emit each word progressively for the live typing effect ──
//         _emitProgressively(result.recognizedWords);
//
//         // Always keep the buffer up to date
//         _buffer = result.recognizedWords;
//
//         // When the engine marks a result as final, resolve the completer
//         if (result.finalResult) {
//           _isListening = false;
//           _voiceState = VoiceState.idle;
//           if (!_completer!.isCompleted) {
//             _completer!.complete(_buffer.trim());
//           }
//         }
//       },
//       listenFor: const Duration(seconds: 60),
//       pauseFor: const Duration(seconds: 10),
//       localeId: resolvedLocale,
//       cancelOnError: false,
//       partialResults: true,
//       listenMode: stt.ListenMode.dictation,
//     );
//
//     // Safety timeout: 32 s — slightly longer than listenFor
//     return _completer!.future.timeout(
//       const Duration(seconds: 32),
//       onTimeout: () {
//         _isListening = false;
//         _voiceState = VoiceState.idle;
//         _speech.stop();
//         final captured = _buffer.trim();
//         if (captured.isNotEmpty) return captured;
//         throw Exception('Listening timed out. Please try again.');
//       },
//     );
//   }
//
//   // ─────────────────────────────────────────────────────────────
//   // Progressive word emission (natural typing effect)
//   // ─────────────────────────────────────────────────────────────
//
//   /// Compares the new text against the previous buffer and emits
//   /// each new word individually with a slight delay so the UI
//   /// shows words appearing one by one — exactly like Google Voice.
//   Future<void> _emitProgressively(String newText) async {
//     final previousWords = _buffer.trim().split(RegExp(r'\s+'));
//     final newWords = newText.trim().split(RegExp(r'\s+'));
//
//     // Only process genuinely new words
//     if (newWords.length <= previousWords.length && _buffer.isNotEmpty) return;
//
//     final start = _buffer.isEmpty ? 0 : previousWords.length;
//
//     for (int i = start; i < newWords.length; i++) {
//       // Build the growing sentence up to word i
//       final partial = newWords.sublist(0, i + 1).join(' ');
//       if (!_transcriptionController.isClosed) {
//         _transcriptionController.add(partial);
//       }
//       // ~120 ms between words — feels natural, not sluggish
//       await Future.delayed(const Duration(milliseconds: 120));
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────
//   // stopListening
//   // ─────────────────────────────────────────────────────────────
//
//   @override
//   Future<void> stopListening() async {
//     await _speech.stop();
//     _isListening = false;
//     _voiceState = VoiceState.idle;
//
//     if (_completer != null && !_completer!.isCompleted) {
//       final captured = _buffer.trim();
//       if (captured.isNotEmpty) {
//         _completer!.complete(captured);
//       } else {
//         _completer!.completeError(
//           Exception('Nothing recognised. Please try again.'),
//         );
//       }
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────
//   // cancelListening
//   // ─────────────────────────────────────────────────────────────
//
//   @override
//   Future<void> cancelListening() async {
//     await _speech.cancel();
//     _isListening = false;
//     _voiceState = VoiceState.idle;
//     _buffer = '';
//
//     // Emit empty string so the UI clears the live text
//     if (!_transcriptionController.isClosed) {
//       _transcriptionController.add('');
//     }
//
//     // Complete with error so callers can handle cancellation gracefully
//     if (_completer != null && !_completer!.isCompleted) {
//       _completer!.completeError(Exception('cancelled'));
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────
//   // dispose
//   // ─────────────────────────────────────────────────────────────
//
//   @override
//   void dispose() {
//     _transcriptionController.close();
//   }
// }
