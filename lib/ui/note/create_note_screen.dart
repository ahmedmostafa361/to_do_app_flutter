// lib/ui/note/create_note_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app_flutter/ui/note/widget/action_button.dart';
import 'package:to_do_app_flutter/ui/note/widget/color_accent_item.dart';
import 'package:to_do_app_flutter/ui/note/widget/symbol_selector_item.dart';
import 'package:to_do_app_flutter/utils/app_colors.dart';
import 'package:to_do_app_flutter/utils/app_text.dart';
import 'package:to_do_app_flutter/utils/app_theme.dart';

import '../../core/services/ai_service.dart';
import '../../core/services/speech_service.dart';
import '../../providers/notes_provider.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  // ──────────────────────────────────────────
  // Controllers & State  (unchanged)
  // ──────────────────────────────────────────

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String _selectedSymbol = 'work';
  int _selectedAccentValue = 0xff7C3AED;
  List<String> _tags = [];
  String? _summary;

  bool _isSummarizing = false;
  bool _isGeneratingTags = false;
  bool _isListening = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────
  // HELPERS  (unchanged)
  // ──────────────────────────────────────────

  static const _symbols = [
    ('work', Icons.work),
    ('shopping_cart', Icons.shopping_cart),
    ('home', Icons.home),
    ('school', Icons.school),
  ];

  static const _accentColors = [
    Color(0xff7C3AED), // primary purple
    Color(0xff3B82F6), // blue
    Color(0xffF59E0B), // amber
  ];

  // ──────────────────────────────────────────
  // AI ACTIONS  (unchanged — same AiService calls)
  // ──────────────────────────────────────────

  Future<void> _onSummarize() async {
    final text = _descController.text.trim();
    if (text.isEmpty) {
      _showSnack('Add a description first.');
      return;
    }

    setState(() => _isSummarizing = true);
    try {
      final ai = context.read<AiService>();
      final result = await ai.summarize(text);
      setState(() => _summary = result);
    } catch (_) {
      _showSnack('Summarization failed. Try again.');
    } finally {
      setState(() => _isSummarizing = false);
    }
  }

  Future<void> _onGenerateTags() async {
    final text = '${_titleController.text} ${_descController.text}'.trim();
    if (text.isEmpty) {
      _showSnack('Add a title or description first.');
      return;
    }

    setState(() => _isGeneratingTags = true);
    try {
      final ai = context.read<AiService>();
      final result = await ai.generateTags(text);
      setState(() => _tags = result);
    } catch (_) {
      _showSnack('Tag generation failed. Try again.');
    } finally {
      setState(() => _isGeneratingTags = false);
    }
  }

  // ──────────────────────────────────────────
  // VOICE  (unchanged — same SpeechService call)
  // ──────────────────────────────────────────

  Future<void> _onVoicePressed() async {
    setState(() => _isListening = true);
    try {
      final speech = context.read<SpeechService>();
      final transcription = await speech.startListening();
      final current = _descController.text;
      _descController.text =
      current.isEmpty ? transcription : '$current $transcription';
    } catch (_) {
      _showSnack('Voice input failed. Try again.');
    } finally {
      setState(() => _isListening = false);
    }
  }

  // ──────────────────────────────────────────
  // SAVE  (unchanged — same NotesProvider call)
  // ──────────────────────────────────────────

  Future<void> _onCreateTask() async {
    final title = _titleController.text.trim();
    final content = _descController.text.trim();

    if (title.isEmpty) {
      _showSnack('Please enter a task headline.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final provider = context.read<NotesProvider>();
      await provider.addNote(
        title: title,
        content: content,
        tags: _tags,
        summary: _summary,
        symbol: _selectedSymbol,
        accentColorValue: _selectedAccentValue,
      );

      if (mounted) Navigator.pop(context);
    } catch (_) {
      _showSnack('Failed to save task. Try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTextStyle.bold14White),
        backgroundColor: AppColors.blackColor.withOpacity(0.92),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
        margin: const EdgeInsets.all(AppSpacing.lg),
      ),
    );
  }

  // ──────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final aiAccent =
    isDark ? AppColors.aiPrimaryColorDark : AppColors.aiPrimaryColor;
    final titleColor = isDark ? AppColors.textPrimaryColorDark : AppColors
        .blackColor;
    final mutedColor =
    isDark ? AppColors.textSecondaryColorDark : AppColors.greyColor;
    final fieldFill =
    isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceContainer;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              width: width,
              height: height * 0.08,
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border:
                Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back, color: primary,
                            size: width * 0.06),
                      ),
                      SizedBox(width: width * 0.02),
                      Text(
                        'Create Task',
                        style: AppTextStyle.bold18Primary.copyWith(
                            color: primary),
                      ),
                    ],
                  ),
                  Icon(Icons.more_vert, color: primary, size: width * 0.06),
                ],
              ),
            ),

            // ── Scrollable body ──
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.03),
                    Text(
                      'Create Task',
                      style: AppTextStyle.extraBold30Black.copyWith(
                          color: titleColor),
                    ),
                    SizedBox(height: height * 0.01),
                    Text(
                      'Focus on one thing at a time. Define your next editorial masterpiece.',
                      style: AppTextStyle.regular16Grey.copyWith(
                          color: mutedColor),
                    ),
                    SizedBox(height: height * 0.04),

                    // ── Title ──
                    Text('TASK HEADLINE',
                        style: AppTextStyle.bold11Grey.copyWith(
                            color: mutedColor)),
                    SizedBox(height: height * 0.01),
                    TextField(
                      controller: _titleController,
                      style: AppTextStyle.extraBold24Black.copyWith(
                          color: titleColor),
                      decoration: InputDecoration(
                        hintText: 'What needs to be done?',
                        hintStyle: AppTextStyle.bold18Black
                            .copyWith(color: mutedColor.withOpacity(0.5)),
                        filled: true,
                        fillColor: fieldFill,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.cardRadius,
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(width * 0.06),
                      ),
                    ),
                    SizedBox(height: height * 0.04),

                    // ── Description ──
                    Text('DESCRIPTION',
                        style: AppTextStyle.bold11Grey.copyWith(
                            color: mutedColor)),
                    SizedBox(height: height * 0.01),
                    Stack(
                      children: [
                        TextField(
                          controller: _descController,
                          maxLines: 4,
                          style: AppTextStyle.regular16Grey.copyWith(
                              color: titleColor),
                          decoration: InputDecoration(
                            hintText: 'Add details or subtasks...',
                            hintStyle: AppTextStyle.regular16Grey
                                .copyWith(color: mutedColor.withOpacity(0.5)),
                            filled: true,
                            fillColor: fieldFill,
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.cardRadius,
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.only(
                              left: width * 0.06,
                              right: width * 0.06,
                              top: width * 0.06,
                              bottom: width * 0.14,
                            ),
                          ),
                        ),
                        // Voice input — same _onVoicePressed call, now
                        // AI-accented and with a highlighted background
                        // while listening, so it's obvious it's live.
                        Positioned(
                          bottom: width * 0.04,
                          right: width * 0.04,
                          child: AnimatedContainer(
                            duration: AppMotion.standard,
                            curve: AppMotion.curve,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isListening
                                  ? aiAccent.withOpacity(0.15)
                                  : Colors.transparent,
                            ),
                            child: IconButton(
                              onPressed: _isListening ? null : _onVoicePressed,
                              icon: _isListening
                                  ? SizedBox(
                                width: width * 0.05,
                                height: width * 0.05,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: aiAccent,
                                ),
                              )
                                  : Icon(Icons.mic, color: aiAccent,
                                  size: width * 0.06),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ── Summary chip (shown after AI summarize) ──
                    if (_summary != null) ...[
                      SizedBox(height: height * 0.015),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(width * 0.04),
                        decoration: BoxDecoration(
                          color: aiAccent.withOpacity(0.08),
                          borderRadius: AppRadius.cardRadius,
                          border: Border.all(color: aiAccent.withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.auto_awesome, color: aiAccent,
                                size: width * 0.045),
                            SizedBox(width: width * 0.02),
                            Expanded(
                              child: Text(_summary!,
                                  style: AppTextStyle.medium15AIPrimary),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _summary = null),
                              child: Icon(Icons.close, color: mutedColor,
                                  size: width * 0.04),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ── Tags chips (shown after AI generate tags) ──
                    if (_tags.isNotEmpty) ...[
                      SizedBox(height: height * 0.015),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: _tags
                            .map(
                              (tag) =>
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: aiAccent.withOpacity(0.1),
                                  borderRadius: AppRadius.chipRadius,
                                ),
                                child: Text(
                                  tag,
                                  style: AppTextStyle.bold10Primary
                                      .copyWith(color: aiAccent),
                                ),
                              ),
                        )
                            .toList(),
                      ),
                    ],

                    SizedBox(height: height * 0.04),

                    // ── AI Actions ──
                    Text('AI ACTIONS',
                        style: AppTextStyle.bold11Grey.copyWith(
                            color: mutedColor)),
                    SizedBox(height: height * 0.015),
                    Row(
                      children: [
                        Expanded(
                          child: ActionButton(
                            width: width,
                            height: height,
                            label: 'Summarize',
                            icon: Icons.auto_awesome,
                            onPressed: _onSummarize,
                            isLoading: _isSummarizing,
                          ),
                        ),
                        SizedBox(width: width * 0.04),
                        Expanded(
                          child: ActionButton(
                            width: width,
                            height: height,
                            label: 'Generate Tags',
                            icon: Icons.sell,
                            onPressed: _onGenerateTags,
                            isLoading: _isGeneratingTags,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.04),

                    // ── Symbol picker ──
                    Text('SYMBOL',
                        style: AppTextStyle.bold11Grey.copyWith(
                            color: mutedColor)),
                    SizedBox(height: height * 0.015),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _symbols
                            .map(
                              (s) => Padding(
                                padding: EdgeInsets.only(right: width * 0.03),
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedSymbol = s.$1),
                                  child: SymbolSelectorItem(
                                    width: width,
                                    icon: s.$2,
                                    isSelected: _selectedSymbol == s.$1,
                                  ),
                                ),
                              ),
                        )
                            .toList(),
                      ),
                    ),

                    SizedBox(height: height * 0.04),

                    // ── Accent color picker ──
                    Text('ACCENT',
                        style: AppTextStyle.bold11Grey.copyWith(
                            color: mutedColor)),
                    SizedBox(height: height * 0.015),
                    Row(
                      children: _accentColors
                          .map(
                            (c) => Padding(
                              padding: EdgeInsets.only(right: width * 0.03),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() =>
                                    _selectedAccentValue = c.value),
                                child: ColorAccentItem(
                                  width: width,
                                  color: c,
                                  isSelected: _selectedAccentValue == c.value,
                                ),
                              ),
                            ),
                      )
                          .toList(),
                    ),

                    SizedBox(height: height * 0.05),

                    // ── Create Task button ──
                    SizedBox(
                      width: width,
                      height: height * 0.075,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _onCreateTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          disabledBackgroundColor: primary.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.buttonRadius,
                          ),
                          elevation: 0,
                        ),
                        icon: _isSaving
                            ? SizedBox(
                          width: width * 0.05,
                          height: width * 0.05,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                            : Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.onPrimary,
                          size: width * 0.06,
                        ),
                        label: Text(
                          _isSaving ? 'SAVING...' : 'CREATE TASK',
                          style: AppTextStyle.bold14White.copyWith(
                            letterSpacing: 1.1,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.04),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}