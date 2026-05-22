// lib/ui/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app_flutter/ui/home/widget/task_list_item.dart';
import 'package:to_do_app_flutter/ui/home/widget/voice-recording_modal.dart';
import 'package:to_do_app_flutter/utils/app_colors.dart';
import 'package:to_do_app_flutter/utils/app_routes.dart';
import 'package:to_do_app_flutter/utils/app_text.dart';

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
      backgroundColor: AppColors.backgroundLight,
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
    return Container(
      width: width,
      padding: EdgeInsets.only(
        left: width * 0.06,
        right: width * 0.06,
        top: height * 0.015,
        bottom: height * 0.015,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(
          bottom: BorderSide(
            color: AppColors.greyLightColor.withOpacity(0.12),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: width * 0.09,
            height: width * 0.09,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor.withOpacity(0.1),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                'AK',
                style: AppTextStyle.bold12Black.copyWith(
                  color: AppColors.primaryColor,
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
                ),
              ),
              Text('Ahmed', style: AppTextStyle.bold18Black),
            ],
          ),
          const Spacer(),
          // AI sparkle button with badge
          Stack(
            children: [
              Container(
                width: width * 0.09,
                height: width * 0.09,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(width * 0.025),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.25),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.primaryColor,
                  size: width * 0.045,
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.shade600,
                    border: Border.all(
                      color: AppColors.backgroundLight,
                      width: 1.5,
                    ),
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

  Widget _buildVoiceActionButton(
    BuildContext context,
    double width,
    double height,
  ) {
    return Positioned(
      bottom: height * 0.04,
      left: width * 0.08,
      child: GestureDetector(
        onTap: () => _showVoiceModal(context),
        child: Container(
          width: width * 0.14,
          height: width * 0.14,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(width * 0.03),
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor.withOpacity(0.15),
                blurRadius: width * 0.06,
                offset: Offset(0, height * 0.01),
              ),
            ],
          ),
          child: Icon(
            Icons.mic,
            color: AppColors.whiteColor,
            size: width * 0.06,
          ),
        ),
      ),
    );
  }

  Widget _buildMainFloatingActionButton(
    BuildContext context,
    double width,
    double height,
  ) {
    return Positioned(
      bottom: height * 0.04,
      right: width * 0.08,
      child: GestureDetector(
        onTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.createTaskScreen),
        child: Container(
          width: width * 0.14,
          height: width * 0.14,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(width * 0.03),
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor.withOpacity(0.15),
                blurRadius: width * 0.06,
                offset: Offset(0, height * 0.01),
              ),
            ],
          ),
          child: Icon(
            Icons.add,
            color: AppColors.whiteColor,
            size: width * 0.07,
          ),
        ),
      ),
    );
  }

  void _showVoiceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundLight.withOpacity(0.95),
      builder: (context) {
        final h = MediaQuery.sizeOf(context).height;
        final w = MediaQuery.sizeOf(context).width;
        return VoiceRecordingModal(width: w, height: h);
      },
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
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        final allNotes = notesProvider.notes;
        final visibleNotes = searchProvider.filter(allNotes);

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.04),
              _buildDashboard(notesProvider),
              SizedBox(height: height * 0.02),
              // Search bar
              _buildSearchBar(context, searchProvider),
              SizedBox(height: height * 0.03),
              if (visibleNotes.isEmpty)
                _buildEmptyState()
              else
                ...visibleNotes.map(
                  (note) => Padding(
                    padding: EdgeInsets.only(bottom: height * 0.02),
                    child: _NoteListItemWrapper(note: note, width: width),
                  ),
                ),
              SizedBox(height: height * 0.12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboard(NotesProvider provider) {
    final total = provider.totalNotes;
    final completed = provider.completedNotes;
    final progress = total == 0 ? 0.0 : completed / total;
    final percent = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good Morning,', style: AppTextStyle.bold36Black),
                  SizedBox(height: height * 0.005),
                  Text(
                    total == 0
                        ? 'No tasks yet. Tap + to create one.'
                        : 'You have $total task${total == 1 ? '' : 's'} today. Stay focused!',
                    style: AppTextStyle.regular16Grey,
                  ),
                ],
              ),
            ),
            // ✅ Circular percent indicator stays
            SizedBox(
              width: width * 0.16,
              height: width * 0.16,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: width * 0.14,
                    height: width * 0.14,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: width * 0.01,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor,
                      ),
                      backgroundColor: AppColors.surfaceContainer,
                    ),
                  ),
                  Text('$percent%', style: AppTextStyle.bold12Black),
                ],
              ),
            ),
          ],
        ),

        // ✅ NEW: animated progress bar below the header row
        if (total > 0) ...[
          SizedBox(height: height * 0.015),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(width * 0.02),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: progress),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: height * 0.008,
                      backgroundColor: AppColors.surfaceContainer,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: width * 0.03),
              Text('$completed/$total', style: AppTextStyle.bold12Black),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, SearchProvider searchProvider) {
    return TextField(
      onChanged: searchProvider.setQuery,
      style: AppTextStyle.regular16Grey.copyWith(color: AppColors.blackColor),
      decoration: InputDecoration(
        hintText: 'Search tasks...',
        hintStyle: AppTextStyle.regular16Grey,
        prefixIcon: Icon(
          Icons.search,
          color: AppColors.greyLightColor,
          size: width * 0.055,
        ),
        suffixIcon: searchProvider.isActive
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: AppColors.greyLightColor,
                  size: width * 0.05,
                ),
                onPressed: searchProvider.clear,
              )
            : null,
        filled: true,
        fillColor: AppColors.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(width * 0.04),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: width * 0.03,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.only(top: height * 0.08),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.greyLightColor,
              size: width * 0.15,
            ),
            SizedBox(height: height * 0.02),
            Text('All clear!', style: AppTextStyle.bold18Black),
            SizedBox(height: height * 0.01),
            Text(
              'Tap + to add your first task.',
              style: AppTextStyle.regular16Grey,
            ),
          ],
        ),
      ),
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
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(width * 0.03),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => notesProvider.deleteNote(note.id),
      child: TaskListItem(
        icon: icon,
        iconColor: Color(note.accentColorValue),
        iconBgColor: Color(note.accentColorValue).withOpacity(0.1),
        title: note.title,
        subtitle: note.summary ?? note.content,
        hasTag: note.tags.isNotEmpty,
        isCompleted: note.isCompleted,
        // ✅ was hardcoded false
        onToggle: () => notesProvider.toggleComplete(note.id), // ✅ NEW
      ),
    );
  }
}
