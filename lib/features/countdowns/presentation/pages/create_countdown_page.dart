import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/entities/countdown.dart';
import '../providers/countdown_providers.dart';
import '../widgets/color_picker_widget.dart';
import '../widgets/emoji_picker_widget.dart';

/// Create or edit a countdown — full-screen modal with premium transitions.
///
/// Supports:
/// - Smart date suggestions (past date → suggest next year)
/// - Emoji & color picker
/// - Recurrence selection
/// - Notification toggle
/// - Context-aware title (Create vs Edit)
class CreateCountdownPage extends ConsumerStatefulWidget {
  final Countdown? existingCountdown;

  const CreateCountdownPage({super.key, this.existingCountdown});

  @override
  ConsumerState<CreateCountdownPage> createState() =>
      _CreateCountdownPageState();
}

class _CreateCountdownPageState extends ConsumerState<CreateCountdownPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _titleController;
  late DateTime _selectedDate;
  late String _selectedEmoji;
  late int _selectedColorIndex;
  late RecurrenceType _selectedRecurrence;
  late bool _notificationsEnabled;

  bool _isEditing = false;
  bool _hasDateSuggestion = false;
  DateTime? _suggestedDate;
  String? _suggestionMessage;

  late final AnimationController _sheetAnimation;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.existingCountdown != null;

    final existing = widget.existingCountdown;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _selectedDate = existing?.targetDate ?? DateTime.now().add(const Duration(days: 7));
    _selectedEmoji = existing?.emoji ?? AppConstants.defaultEmoji;
    _selectedColorIndex = existing?.colorIndex ?? 0;
    _selectedRecurrence = existing?.recurrence ?? RecurrenceType.none;
    _notificationsEnabled = existing?.notificationsEnabled ?? true;

    _sheetAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _sheetAnimation.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sheetAnimation.dispose();
    super.dispose();
  }

  void _checkDateSuggestion() {
    final suggestion = ref.read(suggestDateUseCaseProvider)(_selectedDate);
    setState(() {
      _hasDateSuggestion = suggestion.hasSuggestion;
      _suggestedDate = suggestion.suggestedDate;
      _suggestionMessage = suggestion.message;
    });
  }

  void _acceptSuggestion() {
    if (_suggestedDate != null) {
      AppHaptics.selection();
      setState(() {
        _selectedDate = _suggestedDate!;
        _hasDateSuggestion = false;
        _suggestedDate = null;
        _suggestionMessage = null;
      });
    }
  }

  Future<void> _showDatePicker() async {
    AppHaptics.light();
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: context.isDark
              ? AppColors.surfaceElevatedDark
              : AppColors.surfaceElevated,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.modalRadius),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: context.isDark
                    ? AppColors.separatorDark
                    : AppColors.separator,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                minimumDate: DateTime(2000),
                maximumDate: DateTime(2100),
                onDateTimeChanged: (date) {
                  AppHaptics.selection();
                  setState(() => _selectedDate = date);
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.sm,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    onPressed: () {
                      _checkDateSuggestion();
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker() {
    AppHaptics.light();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmojiPickerWidget(
        selectedEmoji: _selectedEmoji,
        onEmojiSelected: (emoji) {
          AppHaptics.selection();
          setState(() => _selectedEmoji = emoji);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      AppHaptics.error();
      return;
    }

    AppHaptics.success();

    if (_isEditing) {
      final updated = widget.existingCountdown!.copyWith(
        title: title,
        targetDate: _selectedDate,
        emoji: _selectedEmoji,
        colorIndex: _selectedColorIndex,
        recurrence: _selectedRecurrence,
        notificationsEnabled: _notificationsEnabled,
        updatedAt: DateTime.now(),
      );
      await ref.read(countdownsProvider.notifier).update(updated);
    } else {
      await ref.read(countdownsProvider.notifier).create(
            title: title,
            targetDate: _selectedDate,
            emoji: _selectedEmoji,
            colorIndex: _selectedColorIndex,
            recurrence: _selectedRecurrence,
            notificationsEnabled: _notificationsEnabled,
          );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundPrimaryDark
          : AppColors.backgroundPrimary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Nav Bar ────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: isDark
                ? AppColors.backgroundPrimaryDark.withOpacity(0.85)
                : AppColors.backgroundPrimary.withOpacity(0.85),
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(),
              ),
            ),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                AppHaptics.light();
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: AppTypography.body.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
            leadingWidth: 80,
            title: Text(
              _isEditing ? 'Edit Countdown' : 'New Countdown',
              style: AppTypography.headline.copyWith(
                color: isDark
                    ? AppColors.labelPrimaryDark
                    : AppColors.labelPrimary,
              ),
            ),
            centerTitle: true,
            actions: [
              CupertinoButton(
                padding: const EdgeInsets.only(right: AppSpacing.lg),
                onPressed: _titleController.text.trim().isEmpty ? null : _save,
                child: Text(
                  _isEditing ? 'Save' : 'Add',
                  style: AppTypography.headline.copyWith(
                    color: _titleController.text.trim().isEmpty
                        ? (isDark
                            ? AppColors.labelTertiaryDark
                            : AppColors.labelTertiary)
                        : AppColors.accent,
                  ),
                ),
              ),
            ],
          ),

          // ─── Form Content ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),

                  // ─── Emoji & Title ──────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: _showEmojiPicker,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceSecondaryDark
                              : AppColors.surfaceSecondary,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.xxl),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _selectedEmoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ─── Title Field ────────────────────────────
                  _FormSection(
                    isDark: isDark,
                    child: CupertinoTextField(
                      controller: _titleController,
                      placeholder: 'Countdown name',
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: const BoxDecoration(),
                      style: AppTypography.body.copyWith(
                        color: isDark
                            ? AppColors.labelPrimaryDark
                            : AppColors.labelPrimary,
                      ),
                      placeholderStyle: AppTypography.body.copyWith(
                        color: isDark
                            ? AppColors.labelTertiaryDark
                            : AppColors.labelTertiary,
                      ),
                      autofocus: !_isEditing,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ─── Date Selection ─────────────────────────
                  _FormSection(
                    isDark: isDark,
                    child: CupertinoButton(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      onPressed: _showDatePicker,
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.calendar,
                            size: 22,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date',
                                  style: AppTypography.footnote.copyWith(
                                    color: isDark
                                        ? AppColors.labelSecondaryDark
                                        : AppColors.labelSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  dateFormat.format(_selectedDate),
                                  style: AppTypography.body.copyWith(
                                    color: isDark
                                        ? AppColors.labelPrimaryDark
                                        : AppColors.labelPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            CupertinoIcons.chevron_right,
                            size: 16,
                            color: isDark
                                ? AppColors.labelTertiaryDark
                                : AppColors.labelTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── Smart Date Suggestion ──────────────────
                  if (_hasDateSuggestion) ...[
                    const SizedBox(height: AppSpacing.sm),
                    GestureDetector(
                      onTap: _acceptSuggestion,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.buttonRadius),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.lightbulb,
                              size: 18,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                '$_suggestionMessage Tap to use ${dateFormat.format(_suggestedDate!)}',
                                style: AppTypography.footnote.copyWith(
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),

                  // ─── Color Picker ───────────────────────────
                  Text(
                    'Color',
                    style: AppTypography.footnoteSemibold.copyWith(
                      color: isDark
                          ? AppColors.labelSecondaryDark
                          : AppColors.labelSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ColorPickerWidget(
                    selectedIndex: _selectedColorIndex,
                    onColorSelected: (index) {
                      AppHaptics.selection();
                      setState(() => _selectedColorIndex = index);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ─── Recurrence ─────────────────────────────
                  _FormSection(
                    isDark: isDark,
                    child: CupertinoButton(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      onPressed: _showRecurrencePicker,
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.repeat,
                            size: 22,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Repeat',
                                  style: AppTypography.footnote.copyWith(
                                    color: isDark
                                        ? AppColors.labelSecondaryDark
                                        : AppColors.labelSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  _selectedRecurrence.displayName,
                                  style: AppTypography.body.copyWith(
                                    color: isDark
                                        ? AppColors.labelPrimaryDark
                                        : AppColors.labelPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            CupertinoIcons.chevron_right,
                            size: 16,
                            color: isDark
                                ? AppColors.labelTertiaryDark
                                : AppColors.labelTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ─── Notifications Toggle ───────────────────
                  _FormSection(
                    isDark: isDark,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.bell,
                            size: 22,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Notifications',
                              style: AppTypography.body.copyWith(
                                color: isDark
                                    ? AppColors.labelPrimaryDark
                                    : AppColors.labelPrimary,
                              ),
                            ),
                          ),
                          CupertinoSwitch(
                            value: _notificationsEnabled,
                            activeColor: AppColors.accent,
                            onChanged: (value) {
                              AppHaptics.selection();
                              setState(() => _notificationsEnabled = value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.massive),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecurrencePicker() {
    AppHaptics.light();
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Repeat'),
        actions: RecurrenceType.values.map((type) {
          final isSelected = type == _selectedRecurrence;
          return CupertinoActionSheetAction(
            onPressed: () {
              AppHaptics.selection();
              setState(() => _selectedRecurrence = type);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  type.displayName,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.accent
                        : CupertinoColors.label,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.checkmark,
                    size: 18,
                    color: AppColors.accent,
                  ),
                ],
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

/// Rounded form section container matching iOS grouped table style.
class _FormSection extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _FormSection({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfacePrimaryDark : AppColors.surfacePrimary,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
