import 'dart:math' as math;

import '../../core/imports/imports.dart';
import '../../data/models/category_model.dart';
import '../../data/models/question_model.dart';
import '../home/provider/quiz_provider.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Color _difficultyColor(QuestionDifficulty d, BuildContext context) =>
    switch (d) {
      QuestionDifficulty.easy => context.appColors.success,
      QuestionDifficulty.medium => context.appColors.warning,
      QuestionDifficulty.hard => context.colors.error,
      QuestionDifficulty.any => context.colors.primary,
    };

IconData _difficultyIcon(QuestionDifficulty d) => switch (d) {
  QuestionDifficulty.easy => Icons.sentiment_satisfied_rounded,
  QuestionDifficulty.medium => Icons.sentiment_neutral_rounded,
  QuestionDifficulty.hard => Icons.whatshot_rounded,
  QuestionDifficulty.any => Icons.shuffle_rounded,
};

IconData _typeIcon(QuestionType t) => switch (t) {
  QuestionType.multiple => Icons.list_rounded,
  QuestionType.boolean => Icons.toggle_on_rounded,
  QuestionType.any => Icons.shuffle_rounded,
};

String _typeLabel(QuestionType t) => switch (t) {
  QuestionType.multiple => 'Multiple Choice',
  QuestionType.boolean => 'True / False',
  QuestionType.any => 'Any',
};

// ── Page ──────────────────────────────────────────────────────────────────────

class QuizCustomizationPage extends StatefulWidget {
  const QuizCustomizationPage({super.key, required this.category});

  final CategoryModel category;

  @override
  State<QuizCustomizationPage> createState() => _QuizCustomizationPageState();
}

class _QuizCustomizationPageState extends State<QuizCustomizationPage> {
  int _amount = 10;
  QuestionType _type = QuestionType.any;
  QuestionDifficulty _difficulty = QuestionDifficulty.any;

  static const _amounts = [5, 10, 15, 20, 30, 50];

  // ── Constraint helpers ─────────────────────────────────────────────────────

  /// How many questions OpenTDB guarantees for the current difficulty.
  /// Null when question counts haven't loaded yet.
  int? get _difficultyMax {
    final qc = widget.category.questionCount;
    if (qc == null) return null;
    return switch (_difficulty) {
      QuestionDifficulty.any => qc.totalQuestionCount,
      QuestionDifficulty.easy => qc.totalEasyQuestionCount,
      QuestionDifficulty.medium => qc.totalMediumQuestionCount,
      QuestionDifficulty.hard => qc.totalHardQuestionCount,
    };
  }

  /// Conservative effective max when a specific question TYPE is chosen.
  /// OpenTDB splits questions ~60/40 between multiple-choice and T/F on average,
  /// but we have no per-type API. Using 70% of difficulty max as a safe upper
  /// bound prevents the API returning fewer questions than requested.
  int? get _effectiveMax {
    final dm = _difficultyMax;
    if (dm == null) return null;
    if (_type == QuestionType.any) return dm;
    // 70 % floor — always at least 1 to avoid ceiling artifacts.
    return math.max(1, (dm * 0.7).floor());
  }

  bool get _hasEnoughQuestions {
    final max = _effectiveMax;
    return max == null || max >= 5; // minimum sensible quiz size
  }

  bool get _amountOutOfBounds {
    final max = _effectiveMax;
    return max != null && _amount > max;
  }

  /// Switches difficulty and auto-clamps amount to the nearest valid preset.
  void _onDifficultyChanged(QuestionDifficulty d) {
    final qc = widget.category.questionCount;
    final newDiffMax = qc == null
        ? null
        : switch (d) {
            QuestionDifficulty.any => qc.totalQuestionCount,
            QuestionDifficulty.easy => qc.totalEasyQuestionCount,
            QuestionDifficulty.medium => qc.totalMediumQuestionCount,
            QuestionDifficulty.hard => qc.totalHardQuestionCount,
          };

    setState(() {
      _difficulty = d;
      if (newDiffMax != null) {
        final effectiveForType = _type == QuestionType.any
            ? newDiffMax
            : math.max(1, (newDiffMax * 0.7).floor());
        if (_amount > effectiveForType) {
          // Snap to the largest preset that still fits, else to the raw max.
          final valid = _amounts.where((a) => a <= effectiveForType).toList();
          _amount = valid.isNotEmpty ? valid.last : effectiveForType;
        }
      }
    });
  }

  /// Switches type and re-clamps amount when switching to/from a specific type.
  void _onTypeChanged(QuestionType t) {
    setState(() {
      _type = t;
      final dm = _difficultyMax;
      if (dm != null) {
        final effectiveForType = t == QuestionType.any
            ? dm
            : math.max(1, (dm * 0.7).floor());
        if (_amount > effectiveForType) {
          final valid = _amounts.where((a) => a <= effectiveForType).toList();
          _amount = valid.isNotEmpty ? valid.last : effectiveForType;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final qCount = widget.category.questionCount;
    final effectiveMax = _effectiveMax;
    final hasEnough = _hasEnoughQuestions;

    return Scaffold(
      appBar: AppTopBar(title: widget.category.name),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                  vertical: AppSpacing.md,
                ),
                children: [
                  // ── Category stats card ──────────────────────────────────
                  _StatsBanner(category: widget.category)
                      .animate()
                      .fadeIn(duration: AppDurations.normal)
                      .slideY(begin: -0.1, end: 0),
                  SizedBox(height: AppSpacing.lg),

                  // ── Intro copy ───────────────────────────────────────────
                  Text(
                    'Customize your quiz',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(
                        delay: const Duration(milliseconds: 100),
                        duration: AppDurations.normal,
                      ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Tailor your trivia experience — set the number of questions, type, and difficulty.',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ).animate().fadeIn(
                        delay: const Duration(milliseconds: 150),
                        duration: AppDurations.normal,
                      ),
                  SizedBox(height: AppSpacing.lg),

                  // ── Difficulty picker (first — drives amount caps) ────────
                  const _SectionLabel(
                    icon: Icons.bar_chart_rounded,
                    label: 'Difficulty',
                  ).animate().fadeIn(
                        delay: const Duration(milliseconds: 200),
                        duration: AppDurations.normal,
                      ),
                  SizedBox(height: AppSpacing.sm),
                  _DifficultyPicker(
                    selected: _difficulty,
                    onSelected: _onDifficultyChanged,
                    questionCount: qCount,
                  ).animate().fadeIn(
                        delay: const Duration(milliseconds: 250),
                        duration: AppDurations.normal,
                      ),
                  SizedBox(height: AppSpacing.lg),

                  // ── Type picker ──────────────────────────────────────────
                  const _SectionLabel(
                    icon: Icons.category_rounded,
                    label: 'Question Type',
                  ).animate().fadeIn(
                        delay: const Duration(milliseconds: 300),
                        duration: AppDurations.normal,
                      ),
                  SizedBox(height: AppSpacing.sm),
                  _TypePicker(
                    selected: _type,
                    onSelected: _onTypeChanged,
                  ).animate().fadeIn(
                        delay: const Duration(milliseconds: 350),
                        duration: AppDurations.normal,
                      ),
                  // Info note when a specific type is chosen
                  if (_type != QuestionType.any) ...[
                    SizedBox(height: AppSpacing.xs),
                    _InfoNote(
                      icon: Icons.info_outline_rounded,
                      text:
                          'OpenTDB doesn\'t report per-type counts. '
                          'To stay safe, the amount cap is set to 70% of available questions.',
                      color: context.appColors.info,
                    ).animate().fadeIn(duration: AppDurations.fast),
                  ],
                  SizedBox(height: AppSpacing.lg),

                  // ── Amount picker ────────────────────────────────────────
                  Row(
                    children: [
                      const _SectionLabel(
                        icon: Icons.format_list_numbered_rounded,
                        label: 'Number of Questions',
                      ),
                      if (effectiveMax != null) ...[
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2.r,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainerHigh,
                            borderRadius: AppBorders.full,
                            border: Border.all(
                              color: context.colors.outlineVariant,
                            ),
                          ),
                          child: Text(
                            'max $effectiveMax',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ).animate().fadeIn(
                        delay: const Duration(milliseconds: 400),
                        duration: AppDurations.normal,
                      ),
                  SizedBox(height: AppSpacing.sm),

                  // Not-enough-questions warning
                  if (!hasEnough) ...[
                    _InfoNote(
                      icon: Icons.warning_amber_rounded,
                      text:
                          'This category doesn\'t have enough questions '
                          'for the selected difficulty${_type != QuestionType.any ? ' and type' : ''}. '
                          'Try "Any" for more options.',
                      color: context.colors.error,
                    ).animate().fadeIn(duration: AppDurations.fast),
                    SizedBox(height: AppSpacing.sm),
                  ],

                  _AmountPicker(
                    amounts: _amounts,
                    selected: _amount,
                    maxAllowed: effectiveMax,
                    onSelected: (v) => setState(() => _amount = v),
                  ).animate().fadeIn(
                        delay: const Duration(milliseconds: 450),
                        duration: AppDurations.normal,
                      ),
                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),

            // ── Start button ─────────────────────────────────────────────
            _BottomBar(
              amount: _amount,
              type: _type,
              difficulty: _difficulty,
              isLoading: quizProvider.isLoading,
              isBlocked: !hasEnough || _amountOutOfBounds,
              onStart: () async {
                await quizProvider.getQuestions(
                  context: context,
                  categoryId: widget.category.id,
                  amount: _amount,
                  type: _type,
                  difficulty: _difficulty,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats Banner ──────────────────────────────────────────────────────────────

class _StatsBanner extends StatelessWidget {
  final CategoryModel category;

  const _StatsBanner({required this.category});

  @override
  Widget build(BuildContext context) {
    final qCount = category.questionCount;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.primaryContainer,
            context.colors.secondaryContainer,
          ],
        ),
        borderRadius: AppBorders.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.quiz_rounded,
                color: context.colors.onPrimaryContainer,
                size: 20.r,
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  category.name,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onPrimaryContainer,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          if (qCount != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BannerStat(
                  label: 'Total',
                  count: qCount.totalQuestionCount,
                  color: context.colors.onPrimaryContainer,
                ),
                _BannerDivider(),
                _BannerStat(
                  label: 'Easy',
                  count: qCount.totalEasyQuestionCount,
                  color: context.appColors.success,
                ),
                _BannerDivider(),
                _BannerStat(
                  label: 'Medium',
                  count: qCount.totalMediumQuestionCount,
                  color: context.appColors.warning,
                ),
                _BannerDivider(),
                _BannerStat(
                  label: 'Hard',
                  count: qCount.totalHardQuestionCount,
                  color: context.colors.error,
                ),
              ],
            )
          else
            Text(
              'Loading question counts...',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onPrimaryContainer.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _BannerStat({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onPrimaryContainer.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _BannerDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32.h,
      color: context.colors.onPrimaryContainer.withValues(alpha: 0.2),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.r, color: context.colors.primary),
        SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: context.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
      ],
    );
  }
}

// ── Info Note ─────────────────────────────────────────────────────────────────

class _InfoNote extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoNote({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppBorders.md,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14.r, color: color),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: context.textTheme.labelSmall?.copyWith(
                color: color,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Amount Picker ─────────────────────────────────────────────────────────────

class _AmountPicker extends StatelessWidget {
  final List<int> amounts;
  final int selected;
  final int? maxAllowed;
  final ValueChanged<int> onSelected;

  const _AmountPicker({
    required this.amounts,
    required this.selected,
    required this.onSelected,
    this.maxAllowed,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: amounts.map((amount) {
        final isSelected = amount == selected;
        final isDisabled = maxAllowed != null && amount > maxAllowed!;

        return GestureDetector(
          onTap: isDisabled ? null : () => onSelected(amount),
          child: AnimatedContainer(
            duration: AppDurations.fast,
            curve: AppCurves.standard,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isDisabled
                  ? context.colors.surfaceContainerLow
                  : isSelected
                  ? context.colors.primary
                  : context.colors.surfaceContainerHigh,
              borderRadius: AppBorders.full,
              border: Border.all(
                color: isDisabled
                    ? context.colors.outlineVariant.withValues(alpha: 0.4)
                    : isSelected
                    ? context.colors.primary
                    : context.colors.outlineVariant,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$amount',
                  style: context.textTheme.labelLarge?.copyWith(
                    color: isDisabled
                        ? context.colors.onSurface.withValues(alpha: 0.3)
                        : isSelected
                        ? context.colors.onPrimary
                        : context.colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isDisabled) ...[
                  SizedBox(width: 4.r),
                  Icon(
                    Icons.block_rounded,
                    size: 10.r,
                    color: context.colors.onSurface.withValues(alpha: 0.25),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Type Picker ───────────────────────────────────────────────────────────────

class _TypePicker extends StatelessWidget {
  final QuestionType selected;
  final ValueChanged<QuestionType> onSelected;

  const _TypePicker({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: QuestionType.values.map((type) {
        final isSelected = type == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: type != QuestionType.values.last ? AppSpacing.sm : 0,
            ),
            child: GestureDetector(
              onTap: () => onSelected(type),
              child: AnimatedContainer(
                duration: AppDurations.fast,
                curve: AppCurves.standard,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primaryContainer
                      : context.colors.surfaceContainerHigh,
                  borderRadius: AppBorders.md,
                  border: Border.all(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.outlineVariant,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _typeIcon(type),
                      size: 22.r,
                      color: isSelected
                          ? context.colors.primary
                          : context.colors.onSurfaceVariant,
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      _typeLabel(type),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? context.colors.onPrimaryContainer
                            : context.colors.onSurfaceVariant,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Difficulty Picker ─────────────────────────────────────────────────────────

class _DifficultyPicker extends StatelessWidget {
  final QuestionDifficulty selected;
  final ValueChanged<QuestionDifficulty> onSelected;
  final CategoryQuestionCountModel? questionCount;

  const _DifficultyPicker({
    required this.selected,
    required this.onSelected,
    this.questionCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: QuestionDifficulty.values.map((difficulty) {
        final isSelected = difficulty == selected;
        final color = _difficultyColor(difficulty, context);
        final icon = _difficultyIcon(difficulty);

        final count = switch (difficulty) {
          QuestionDifficulty.easy => questionCount?.totalEasyQuestionCount,
          QuestionDifficulty.medium => questionCount?.totalMediumQuestionCount,
          QuestionDifficulty.hard => questionCount?.totalHardQuestionCount,
          QuestionDifficulty.any => questionCount?.totalQuestionCount,
        };

        // Warn if this specific difficulty has very few questions
        final isScarce = count != null && count < 5;

        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: GestureDetector(
            onTap: () => onSelected(difficulty),
            child: AnimatedContainer(
              duration: AppDurations.fast,
              curve: AppCurves.standard,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.1)
                    : context.colors.surfaceContainerHigh,
                borderRadius: AppBorders.md,
                border: Border.all(
                  color: isSelected ? color : context.colors.outlineVariant,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: AppBorders.sm,
                    ),
                    child: Icon(icon, color: color, size: 18.r),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          difficulty.name[0].toUpperCase() +
                              difficulty.name.substring(1),
                          style: context.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? color : context.colors.onSurface,
                          ),
                        ),
                        if (count != null)
                          Text(
                            isScarce
                                ? '⚠ Only $count questions — may be insufficient'
                                : '$count questions available',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: isScarce
                                  ? context.colors.error
                                  : context.colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded, color: color, size: 20.r),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Bottom Bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int amount;
  final QuestionType type;
  final QuestionDifficulty difficulty;
  final bool isLoading;
  final bool isBlocked;
  final VoidCallback onStart;

  const _BottomBar({
    required this.amount,
    required this.type,
    required this.difficulty,
    required this.isLoading,
    required this.isBlocked,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.md,
        AppSpacing.pagePadding,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(color: context.colors.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 13.r,
                color: context.colors.onSurfaceVariant,
              ),
              SizedBox(width: AppSpacing.xxs),
              Text(
                '$amount questions · ${_typeLabel(type)} · ${difficulty.name.toUpperCase()}',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          AppButton(
            label: isBlocked ? 'Not Enough Questions' : 'Start Quiz',
            isLoading: isLoading,
            isFullWidth: true,
            height: ButtonSize.large,
            prefixIcon: Icon(
              isBlocked ? Icons.block_rounded : Icons.play_arrow_rounded,
              size: 20.r,
            ),
            onPressed: (isLoading || isBlocked) ? null : onStart,
          ),
        ],
      ),
    );
  }
}
