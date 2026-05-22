import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/ai_service.dart';
import '../../../core/services/speech_service.dart';
import '../../../providers/notes_provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text.dart';

enum _VoiceState { idle, listening, processing, done, error }

class VoiceRecordingModal extends StatefulWidget {
  final double width;
  final double height;

  const VoiceRecordingModal({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  State<VoiceRecordingModal> createState() => _VoiceRecordingModalState();
}

class _VoiceRecordingModalState extends State<VoiceRecordingModal> {
  _VoiceState _state = _VoiceState.idle;
  String _liveText = '';
  String _finalText = '';
  String _errorMessage = '';

  // What was actually saved — shown in the done card
  String _savedTitle = '';
  String _savedContent = '';
  List<String> _savedTags = [];

  StreamSubscription<String>? _streamSub;

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // Flow
  // ─────────────────────────────────────────────────────────────

  Future<void> _startFlow() async {
    setState(() {
      _state = _VoiceState.listening;
      _liveText = '';
      _finalText = '';
      _errorMessage = '';
      _savedTitle = '';
      _savedContent = '';
      _savedTags = [];
    });

    try {
      final speech = context.read<SpeechService>();

      // Subscribe to live word stream
      await _streamSub?.cancel();
      _streamSub = speech.transcriptionStream.listen((partial) {
        if (mounted) setState(() => _liveText = partial);
      });

      // Wait for user to finish speaking
      final text = await speech.startListening(localeId: 'en');

      await _streamSub?.cancel();
      _streamSub = null;

      if (!mounted) return;
      if (text.trim().isEmpty)
        throw Exception('Nothing recognised. Please try again.');

      setState(() {
        _finalText = text;
        _liveText = text;
        _state = _VoiceState.processing;
      });

      // ── ONE AI call → title + description + tags ────────────
      // extractTask guarantees title ≠ description
      final ai = context.read<AiService>();
      final task = await ai.extractTask(text);

      if (!mounted) return;

      // Save to provider
      await context.read<NotesProvider>().addNote(
        title: task.title,
        content: task.description,
        tags: task.tags,
        summary: null,
        symbol: 'work',
        accentColorValue: 0xff7C3AED,
      );

      if (!mounted) return;

      setState(() {
        _savedTitle = task.title;
        _savedContent = task.description;
        _savedTags = task.tags;
        _state = _VoiceState.done;
      });

      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      await _streamSub?.cancel();
      _streamSub = null;

      final msg = e.toString().replaceFirst('Exception: ', '');
      if (msg == 'cancelled') {
        if (mounted) Navigator.pop(context);
        return;
      }
      if (mounted) {
        setState(() {
          _state = _VoiceState.error;
          _errorMessage = msg;
        });
      }
    }
  }

  Future<void> _stop() async => context.read<SpeechService>().stopListening();

  Future<void> _cancel() async =>
      context.read<SpeechService>().cancelListening();

  // ─────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final w = widget.width;
    final h = widget.height;

    return Container(
      height: h,
      padding: EdgeInsets.symmetric(horizontal: w * 0.08, vertical: h * 0.04),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // ── Mic button ──
          GestureDetector(
            onTap: _state == _VoiceState.idle || _state == _VoiceState.error
                ? _startFlow
                : _state == _VoiceState.listening
                ? _stop
                : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: _state == _VoiceState.listening ? w * 0.30 : w * 0.24,
                  height: _state == _VoiceState.listening ? w * 0.30 : w * 0.24,
                  decoration: BoxDecoration(
                    color: _ringColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: w * 0.20,
                  height: w * 0.20,
                  decoration: BoxDecoration(
                    color: _ringColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _ringColor.withOpacity(0.35),
                        blurRadius: w * 0.06,
                        offset: Offset(0, w * 0.015),
                      ),
                    ],
                  ),
                  child: _micContent(w),
                ),
              ],
            ),
          ),

          SizedBox(height: h * 0.05),

          // ── Status ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _statusText,
              key: ValueKey(_statusText),
              style: AppTextStyle.bold24PrimaryAnimated,
            ),
          ),

          SizedBox(height: h * 0.015),

          // ── Content area ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.02),
            child: _buildContentArea(w, h),
          ),

          const Spacer(),

          if (_state == _VoiceState.listening)
            _actionButton(w, h, 'Stop', Icons.stop_rounded, _stop),

          if (_state == _VoiceState.error)
            _actionButton(w, h, 'Try Again', Icons.refresh_rounded, _startFlow),

          SizedBox(height: h * 0.02),

          if (_state != _VoiceState.processing && _state != _VoiceState.done)
            TextButton(
              onPressed: _state == _VoiceState.listening
                  ? _cancel
                  : () => Navigator.pop(context),
              child: Text('Cancel', style: AppTextStyle.bold16Grey),
            ),

          SizedBox(height: h * 0.02),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Content area per state
  // ─────────────────────────────────────────────────────────────

  Widget _buildContentArea(double w, double h) {
    switch (_state) {
      // ── Idle ────────────────────────────────────────────────
      case _VoiceState.idle:
        return Text(
          'Tap the mic and speak your task',
          style: AppTextStyle.regular18GreyItalic,
          textAlign: TextAlign.center,
        );

      // ── Listening: raw live words ────────────────────────────
      case _VoiceState.listening:
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          child: _liveText.isNotEmpty
              ? Text(
                  '"$_liveText"',
                  key: ValueKey(_liveText),
                  style: AppTextStyle.regular18GreyItalic,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                )
              : Text(
                  'Speak your task clearly...',
                  style: AppTextStyle.regular18GreyItalic,
                ),
        );

      // ── Processing ───────────────────────────────────────────
      case _VoiceState.processing:
        return Column(
          children: [
            Text(
              '"$_finalText"',
              style: AppTextStyle.regular18GreyItalic,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: h * 0.01),
            Text('Building your task...', style: AppTextStyle.regular16Grey),
          ],
        );

      // ── Done: show title vs description side by side ─────────
      case _VoiceState.done:
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(w * 0.045),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(w * 0.04),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green.shade500,
                    size: w * 0.05,
                  ),
                  SizedBox(width: w * 0.02),
                  Text(
                    'Saved to your tasks',
                    style: AppTextStyle.regular16Grey.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              Divider(color: Colors.green.shade100, height: h * 0.025),

              // Title row
              _savedRow(
                w,
                h,
                icon: Icons.title_rounded,
                label: 'Title',
                value: _savedTitle,
              ),

              SizedBox(height: h * 0.012),

              // Description row — always different from title
              _savedRow(
                w,
                h,
                icon: Icons.notes_rounded,
                label: 'Description',
                value: _savedContent,
              ),

              // Tags
              if (_savedTags.isNotEmpty) ...[
                SizedBox(height: h * 0.012),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.sell_rounded,
                      color: AppColors.primaryColor,
                      size: w * 0.04,
                    ),
                    SizedBox(width: w * 0.02),
                    Expanded(
                      child: Wrap(
                        spacing: w * 0.02,
                        runSpacing: w * 0.01,
                        children: _savedTags
                            .map(
                              (tag) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.025,
                                  vertical: w * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(w * 0.02),
                                ),
                                child: Text(
                                  tag,
                                  style: AppTextStyle.bold10Primary,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );

      // ── Error ────────────────────────────────────────────────
      case _VoiceState.error:
        return Text(
          _errorMessage,
          style: AppTextStyle.regular16Grey.copyWith(
            color: Colors.red.shade400,
          ),
          textAlign: TextAlign.center,
        );
    }
  }

  /// One labelled row inside the done card.
  Widget _savedRow(
    double w,
    double h, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryColor, size: w * 0.04),
        SizedBox(width: w * 0.02),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyle.bold11Grey.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: h * 0.003),
              Text(
                value,
                style: AppTextStyle.regular16Grey.copyWith(
                  color: Colors.black87,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────

  Widget _micContent(double w) {
    if (_state == _VoiceState.processing) {
      return Padding(
        padding: EdgeInsets.all(w * 0.055),
        child: const CircularProgressIndicator(
          color: AppColors.whiteColor,
          strokeWidth: 2.5,
        ),
      );
    }
    if (_state == _VoiceState.done) {
      return Icon(
        Icons.check_rounded,
        color: AppColors.whiteColor,
        size: w * 0.09,
      );
    }
    return Icon(
      _state == _VoiceState.listening ? Icons.mic : Icons.mic_none_rounded,
      color: AppColors.whiteColor,
      size: w * 0.09,
    );
  }

  Widget _actionButton(
    double w,
    double h,
    String label,
    IconData icon,
    Future<void> Function() onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.whiteColor, size: w * 0.05),
      label: Text(label, style: AppTextStyle.bold16White),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        minimumSize: Size(w, h * 0.065),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(w * 0.03),
        ),
        elevation: 0,
      ),
    );
  }

  String get _statusText {
    switch (_state) {
      case _VoiceState.idle:
        return 'Tap to start';
      case _VoiceState.listening:
        return 'Listening...';
      case _VoiceState.processing:
        return 'Creating task...';
      case _VoiceState.done:
        return 'Task created!';
      case _VoiceState.error:
        return 'Something went wrong';
    }
  }

  Color get _ringColor {
    switch (_state) {
      case _VoiceState.listening:
        return Colors.red.shade400;
      case _VoiceState.processing:
        return AppColors.primaryColor.withOpacity(0.7);
      case _VoiceState.done:
        return Colors.green.shade400;
      case _VoiceState.error:
        return Colors.red.shade300;
      case _VoiceState.idle:
        return AppColors.primaryColor;
    }
  }
}
