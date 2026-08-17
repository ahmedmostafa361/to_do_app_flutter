// lib/ui/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app_flutter/ui/home/widget/task_list_item.dart';
import 'package:to_do_app_flutter/ui/home/widget/voice-recording_modal.dart';
import 'package:to_do_app_flutter/utils/app_colors.dart';
import 'package:to_do_app_flutter/utils/app_routes.dart';
import 'package:to_do_app_flutter/utils/app_text.dart';
import 'package:to_do_app_flutter/utils/app_theme.dart';

import '../../models/note_model.dart';
import '../../providers/notes_provider.dart';
import '../../providers/search_provider.dart';

class TodoHomeScreen extends StatelessWidget {
  const TodoHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopAppBar(context, width, height),
                Expanded(
                  child: _NotesList(width: width, height: height),
                ),
              ],
            ),
          ),
          _buildVoiceActionButton(context, width, height),
          _buildMainFloatingActionButton(context, width, height),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // TOP BAR
  // ──────────────────────────────────────────

  Widget _buildTopAppBar(BuildContext context, double width, double height) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final aiAccent =
    isDark ? AppColors.aiPrimaryColorDark : AppColors.aiPrimaryColor;
    final titleColor = isDark ? AppColors.textPrimaryColorDark : AppColors
        .blackColor;
    final mutedColor =
    isDark ? AppColors.textSecondaryColorDark : AppColors.greyColor;

    return Container(
      width: width,
      padding: EdgeInsets.only(
        left: width * 0.06,
        right: width * 0.06,
        top: height * 0.015,
        bottom: height * 0.015,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: width * 0.09,
            height: width * 0.09,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withOpacity(0.1),
              border: Border.all(color: primary.withOpacity(0.2), width: 1),
            ),
            child: Center(
              child: Text(
                'AK',
                style: AppTextStyle.bold12Black.copyWith(
                  color: primary,
                  fontSize: width * 0.03,
                ),
              ),
            ),
          ),
          SizedBox(width: width * 0.03),
          // Greeting + title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back',
                style: AppTextStyle.regular14Grey.copyWith(
                  fontSize: width * 0.028,
                  color: mutedColor,
                ),
              ),
              Text('Ahmed',
                  style: AppTextStyle.bold18Black.copyWith(color: titleColor)),
            ],
          ),
          const Spacer(),
          // AI identity badge — purely visual (no tap target existed
          // before, none added here — there's no AI chat screen to
          // route to under the agreed restyle-only scope).
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: width * 0.09,
                height: width * 0.09,
                decoration: BoxDecoration(
                  color: aiAccent.withOpacity(0.1),
                  borderRadius: AppRadius.buttonRadius,
                  border: Border.all(
                      color: aiAccent.withOpacity(0.25), width: 1),
                ),
                child: Icon(
                    Icons.auto_awesome, color: aiAccent, size: width * 0.045),
              ),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentAmberColor,
                    border:
                    Border.all(
                        color: theme.scaffoldBackgroundColor, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // FABs
  // ──────────────────────────────────────────

  Widget _buildVoiceActionButton(BuildContext context,
      double width,
      double height,) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final aiAccent =
    isDark ? AppColors.aiPrimaryColorDark : AppColors.aiPrimaryColor;

    return Positioned(
      bottom: height * 0.04,
      left: width * 0.08,
      child: _FabButton(
        size: width * 0.14,
        background: aiAccent,
        icon: Icons.mic,
        onTap: () => _showVoiceModal(context),
      ),
    );
  }

  Widget _buildMainFloatingActionButton(BuildContext context,
      double width,
      double height,) {
    final primary = Theme
        .of(context)
        .colorScheme
        .primary;

    return Positioned(
      bottom: height * 0.04,
      right: width * 0.08,
      child: _FabButton(
        size: width * 0.14,
        background: primary,
        icon: Icons.add,
        iconSize: width * 0.07,
        onTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.createTaskScreen),
      ),
    );
  }

  void _showVoiceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme
          .of(context)
          .scaffoldBackgroundColor
          .withOpacity(0.97),
      builder: (context) {
        final h = MediaQuery.sizeOf(context).height;
        final w = MediaQuery.sizeOf(context).width;
        return VoiceRecordingModal(width: w, height: h);
      },
    );
  }
}

// ──────────────────────────────────────────
// REUSABLE FAB WITH PRESS-SCALE FEEDBACK
// ──────────────────────────────────────────

class _FabButton extends StatefulWidget {
  final double size;
  final Color background;
  final IconData icon;
  final double? iconSize;
  final VoidCallback onTap;

  const _FabButton({
    required this.size,
    required this.background,
    required this.icon,
    required this.onTap,
    this.iconSize,
  });

  @override
  State<_FabButton> createState() => _FabButtonState();
}

class _FabButtonState extends State<_FabButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.curve,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.background,
            borderRadius: AppRadius.cardRadius,
            boxShadow: [
              BoxShadow(
                color: widget.background.withOpacity(0.35),
                blurRadius: widget.size * 0.35,
                offset: Offset(0, widget.size * 0.08),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: AppColors.whiteColor,
            size: widget.iconSize ?? widget.size * 0.42,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// EXTRACTED SCROLLABLE CONTENT WITH CONSUMERS
// ──────────────────────────────────────────

class _NotesList extends StatelessWidget {
  final double width;
  final double height;

  const _NotesList({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotesProvider, SearchProvider>(
      builder: (context, notesProvider, searchProvider, _) {
        if (notesProvider.isLoading) {
          return _buildLoadingState(context);
        }

        final allNotes = notesProvider.notes;
        final visibleNotes = searchProvider.filter(allNotes);
        final incomplete = visibleNotes.where((n) => !n.isCompleted).toList();
        final completed = visibleNotes.where((n) => n.isCompleted).toList();

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.03),
              _buildDashboard(context, notesProvider),
              SizedBox(height: height * 0.025),
              _buildSearchBar(context, searchProvider),
              SizedBox(height: height * 0.03),

              if (allNotes.isEmpty)
                _buildEmptyState(context, isSearchMiss: false)
              else
                if (visibleNotes.isEmpty)
                  _buildEmptyState(context, isSearchMiss: true)
                else
                  ...[
                    if (incomplete.isNotEmpty) ...[
                      _sectionHeader(context, 'TO DO', incomplete.length),
                      SizedBox(height: height * 0.012),
                      ...incomplete
                          .asMap()
                          .entries
                          .map(
                            (e) =>
                            Padding(
                              padding: EdgeInsets.only(bottom: height * 0.02),
                              child: _AnimatedListEntry(
                                index: e.key,
                                child:
                                _NoteListItemWrapper(
                                    note: e.value, width: width),
                              ),
                            ),
                      ),
                    ],
                    if (completed.isNotEmpty) ...[
                      SizedBox(height: height * 0.01),
                      _sectionHeader(context, 'COMPLETED', completed.length),
                      SizedBox(height: height * 0.012),
                      ...completed
                          .asMap()
                          .entries
                          .map(
                            (e) =>
                            Padding(
                              padding: EdgeInsets.only(bottom: height * 0.02),
                              child: _AnimatedListEntry(
                                index: e.key,
                                child:
                                _NoteListItemWrapper(
                                    note: e.value, width: width),
                              ),
                            ),
                      ),
                    ],
                  ],

              SizedBox(height: height * 0.12),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(BuildContext context, String label, int count) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final mutedColor =
    isDark ? AppColors.textSecondaryColorDark : AppColors.greyColor;

    return Row(
      children: [
        Text(label, style: AppTextStyle.bold11Grey.copyWith(color: mutedColor)),
        SizedBox(width: width * 0.015),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: 1),
          decoration: BoxDecoration(
            color: mutedColor.withOpacity(0.12),
            borderRadius: AppRadius.chipRadius,
          ),
          child: Text(
            '$count',
            style: AppTextStyle.bold10Primary.copyWith(color: mutedColor),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final primary = Theme
        .of(context)
        .colorScheme
        .primary;
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: height * 0.25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: width * 0.08,
              height: width * 0.08,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(primary),
              ),
            ),
            SizedBox(height: height * 0.02),
            Text('Loading your tasks...', style: AppTextStyle.regular14Grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, NotesProvider provider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final titleColor = isDark ? AppColors.textPrimaryColorDark : AppColors
        .blackColor;
    final mutedColor =
    isDark ? AppColors.textSecondaryColorDark : AppColors.greyColor;
    final trackColor =
    isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceContainer;

    final total = provider.totalNotes;
    final completed = provider.completedNotes;
    final progress = total == 0 ? 0.0 : completed / total;
    final percent = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_formattedDate(),
            style: AppTextStyle.bold11Grey.copyWith(color: mutedColor)),
        SizedBox(height: height * 0.006),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_greeting()},',
                    style: AppTextStyle.bold36Black.copyWith(color: titleColor),
                  ),
                  SizedBox(height: height * 0.005),
                  Text(
                    total == 0
                        ? 'No tasks yet. Tap + to create one.'
                        : 'You have $total task${total == 1 ? '' : 's'} today. Stay focused!',
                    style: AppTextStyle.regular16Grey.copyWith(
                        color: mutedColor),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: width * 0.16,
              height: width * 0.16,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: width * 0.14,
                    height: width * 0.14,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: progress),
                      duration: AppMotion.slow,
                      curve: AppMotion.curve,
                      builder: (context, value, _) =>
                          CircularProgressIndicator(
                            value: value,
                            strokeWidth: width * 0.01,
                            valueColor: AlwaysStoppedAnimation<Color>(primary),
                            backgroundColor: trackColor,
                      ),
                    ),
                  ),
                  Text('$percent%', style: AppTextStyle.bold12Black.copyWith(
                      color: titleColor)),
                ],
              ),
            ),
          ],
        ),

        if (total > 0) ...[
          SizedBox(height: height * 0.015),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: AppRadius.chipRadius,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: progress),
                    duration: AppMotion.slow,
                    curve: AppMotion.curve,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: height * 0.008,
                      backgroundColor: trackColor,
                      valueColor: AlwaysStoppedAnimation<Color>(primary),
                    ),
                  ),
                ),
              ),
              SizedBox(width: width * 0.03),
              Text('$completed/$total',
                  style: AppTextStyle.bold12Black.copyWith(color: titleColor)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, SearchProvider searchProvider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fillColor =
    isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceContainer;
    final textColor = isDark ? AppColors.textPrimaryColorDark : AppColors
        .blackColor;
    final iconColor =
    isDark ? AppColors.textMutedColorDark : AppColors.greyLightColor;

    return TextField(
      onChanged: searchProvider.setQuery,
      style: AppTextStyle.regular16Grey.copyWith(color: textColor),
      decoration: InputDecoration(
        hintText: 'Search tasks...',
        hintStyle: AppTextStyle.regular16Grey.copyWith(color: iconColor),
        prefixIcon: Icon(Icons.search, color: iconColor, size: width * 0.055),
        suffixIcon: searchProvider.isActive
            ? IconButton(
          icon: Icon(Icons.clear, color: iconColor, size: width * 0.05),
          onPressed: searchProvider.clear,
        )
            : null,
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: AppRadius.cardRadius,
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: width * 0.03,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool isSearchMiss}) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final mutedColor =
    isDark ? AppColors.textSecondaryColorDark : AppColors.greyColor;
    final titleColor = isDark ? AppColors.textPrimaryColorDark : AppColors
        .blackColor;
    final iconColor =
    isDark ? AppColors.textMutedColorDark : AppColors.greyLightColor;

    return Padding(
      padding: EdgeInsets.only(top: height * 0.08),
      child: Center(
        child: Column(
          children: [
            Icon(
              isSearchMiss ? Icons.search_off_rounded : Icons
                  .check_circle_outline,
              color: iconColor,
              size: width * 0.15,
            ),
            SizedBox(height: height * 0.02),
            Text(
              isSearchMiss ? 'No matches' : 'All clear!',
              style: AppTextStyle.bold18Black.copyWith(color: titleColor),
            ),
            SizedBox(height: height * 0.01),
            Text(
              isSearchMiss
                  ? 'Try a different search term.'
                  : 'Tap + to add your first task.',
              style: AppTextStyle.regular16Grey.copyWith(color: mutedColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// STAGGERED FADE / SLIDE ENTRANCE FOR CARDS
// ──────────────────────────────────────────

class _AnimatedListEntry extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedListEntry({required this.child, required this.index});

  @override
  State<_AnimatedListEntry> createState() => _AnimatedListEntryState();
}

class _AnimatedListEntryState extends State<_AnimatedListEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.slow);
    _fade = CurvedAnimation(parent: _controller, curve: AppMotion.curve);
    _slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: AppMotion.curve));

    // Staggered by list position, capped so long lists don't feel laggy.
    final delay = Duration(milliseconds: 30 * widget.index.clamp(0, 8));
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ──────────────────────────────────────────
// NOTE LIST ITEM WRAPPER (adds swipe-to-delete + tap)
// ──────────────────────────────────────────

class _NoteListItemWrapper extends StatelessWidget {
  final NoteModel note;
  final double width;

  const _NoteListItemWrapper({required this.note, required this.width});

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.read<NotesProvider>();

    // Map stored symbol string to IconData
    final iconMap = {
      'work': Icons.assignment,
      'shopping_cart': Icons.shopping_cart,
      'home': Icons.home,
      'school': Icons.school,
      'mail': Icons.mail,
    };
    final icon = iconMap[note.symbol] ?? Icons.assignment;

    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: width * 0.06),
        decoration: BoxDecoration(
          color: AppColors.errorColor,
          borderRadius: AppRadius.cardRadius,
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.whiteColor),
      ),
      onDismissed: (_) => notesProvider.deleteNote(note.id),
      child: TaskListItem(
        icon: icon,
        iconColor: Color(note.accentColorValue),
        iconBgColor: Color(note.accentColorValue).withOpacity(0.1),
        title: note.title,
        subtitle: note.summary ?? note.content,
        tags: note.tags,
        isCompleted: note.isCompleted,
        onToggle: () => notesProvider.toggleComplete(note.id),
      ),
    );
  }
}

// ──────────────────────────────────────────
// DATE / GREETING HELPERS
// (real DateTime.now() computation — no invented data, no new deps)
// ──────────────────────────────────────────

String _greeting() {
  final hour = DateTime
      .now()
      .hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}

String _formattedDate() {
  const weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  final now = DateTime.now();
  return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
}