import 'dart:math' as math;

import '../../core/imports/imports.dart';
import '../../data/models/question_model.dart';
import 'provider/quiz_provider.dart';

// ── Answer option letter labels ───────────────────────────────────────────────
const _optionLabels = ['A', 'B', 'C', 'D'];

Color _difficultyColor(QuestionDifficulty d, BuildContext context) =>
    switch (d) {
      QuestionDifficulty.easy => context.appColors.success,
      QuestionDifficulty.medium => context.appColors.warning,
      QuestionDifficulty.hard => context.colors.error,
      QuestionDifficulty.any => context.colors.primary,
    };

// ── Page ──────────────────────────────────────────────────────────────────────

class QuizQuestionPage extends StatefulWidget {
  const QuizQuestionPage({super.key});

  @override
  State<QuizQuestionPage> createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends State<QuizQuestionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _onQuitPressed() async {
    final shouldQuit = await context.showAppDialog<bool>(
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppBorders.dialog),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: context.colors.error,
              size: 22.r,
            ),
            SizedBox(width: AppSpacing.xs),
            const Text('Quit Quiz?'),
          ],
        ),
        content: const Text(
          'Your progress will be lost and won\'t be counted. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Keep Playing'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.errorContainer,
              foregroundColor: context.colors.onErrorContainer,
            ),
            onPressed: () => ctx.pop(true),
            child: const Text('Quit'),
          ),
        ],
      ),
    );

    if ((shouldQuit ?? false) && mounted) {
      context.read<QuizProvider>().quitQuiz();
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();

    // Navigate to result when finished
    if (provider.status == QuizStatus.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final result = provider.buildResult();
          context.go(AppRoutes.quizResult, extra: result);
        }
      });
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: context.colors.primary),
        ),
      );
    }

    if (provider.questions.isEmpty ||
        provider.currentIndex >= provider.questions.length) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: context.colors.primary),
        ),
      );
    }

    final question = provider.questions[provider.currentIndex];
    final totalQuestions = provider.questions.length;
    final progress = (provider.currentIndex + 1) / totalQuestions;
    final isLastQuestion = provider.currentIndex >= totalQuestions - 1;
    final isLowTime = provider.timeLeft <= 5;
    final diffColor = _difficultyColor(question.difficulty, context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onQuitPressed();
      },
      child: Scaffold(
        // ── App bar ─────────────────────────────────────────────────────────
        appBar: _QuizAppBar(
          current: provider.currentIndex + 1,
          total: totalQuestions,
          score: provider.score,
          onQuit: _onQuitPressed,
          preferredHeight: kToolbarHeight + 1,
        ),
        body: SafeArea(
          child: Column(
            children: [
              AppSpacing.xxs.verticalSpace,
              // ── Quiz progress bar ────────────────────────────────────────
              AnimatedContainer(
                duration: AppDurations.fast,
                height: 4.h,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: context.colors.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation(context.colors.primary),
                  borderRadius: AppBorders.full,
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.lg,
                    AppSpacing.pagePadding,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Meta row: category, difficulty, timer ──────────
                      Row(
                        children: [
                          // Category + difficulty
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  question.category,
                                  style: context.textTheme.labelMedium
                                      ?.copyWith(
                                        color: context.colors.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: AppSpacing.xxs),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 2.r,
                                  ),
                                  decoration: BoxDecoration(
                                    color: diffColor.withValues(alpha: 0.12),
                                    borderRadius: AppBorders.full,
                                  ),
                                  child: Text(
                                    question.difficulty.name.toUpperCase(),
                                    style: context.textTheme.labelSmall
                                        ?.copyWith(
                                          color: diffColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          // Circular timer
                          _CircularTimer(
                            timeLeft: provider.timeLeft,
                            total: 15,
                            isLowTime: isLowTime,
                            pulseController: _pulseController,
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xl),

                      // ── Question text ─────────────────────────────────
                      Text(
                            question.question,
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: AppDurations.normal)
                          .slideY(
                            begin: 0.05,
                            end: 0,
                            duration: AppDurations.normal,
                          ),
                      SizedBox(height: AppSpacing.xl),

                      // ── Answer options ────────────────────────────────
                      ...List.generate(provider.shuffledAnswers.length, (i) {
                        final answer = provider.shuffledAnswers[i];
                        final isSelected = provider.selectedAnswer == answer;
                        return Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _AnswerOption(
                            label: i < _optionLabels.length
                                ? _optionLabels[i]
                                : '${i + 1}',
                            text: answer,
                            isSelected: isSelected,
                            delay: Duration(milliseconds: 100 + i * 70),
                            onTap: () => provider.selectAnswer(answer),
                          ),
                        );
                      }),
                      SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),

              // ── Bottom action bar ────────────────────────────────────────
              _BottomActionBar(
                currentIndex: provider.currentIndex,
                totalQuestions: totalQuestions,
                isLastQuestion: isLastQuestion,
                hasSelection: provider.selectedAnswer != null,
                onNext: () => provider.confirmNext(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quiz AppBar ───────────────────────────────────────────────────────────────

class _QuizAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int current;
  final int total;
  final int score;
  final VoidCallback onQuit;
  final double preferredHeight;

  const _QuizAppBar({
    required this.current,
    required this.total,
    required this.score,
    required this.onQuit,
    required this.preferredHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: context.colors.surface.withValues(alpha: 0.95),
      surfaceTintColor: Colors.transparent,
      leadingWidth: 56.w,
      leading: Padding(
        padding: EdgeInsets.only(left: AppSpacing.sm),
        child: GestureDetector(
          onTap: onQuit,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: context.colors.errorContainer,
              borderRadius: AppBorders.md,
            ),
            child: Icon(
              Icons.close_rounded,
              size: 18.r,
              color: context.colors.onErrorContainer,
            ),
          ),
        ),
      ),
      title: Column(
        children: [
          Text(
            'Question $current of $total',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: AppSpacing.md),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [context.colors.primary, context.colors.tertiary],
            ),
            borderRadius: AppBorders.full,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bolt_rounded,
                color: context.colors.onPrimary,
                size: 14.r,
              ),
              SizedBox(width: 2.r),
              Text(
                '$score pts',
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(preferredHeight);
}

// ── Circular Timer ────────────────────────────────────────────────────────────

class _CircularTimer extends StatelessWidget {
  final int timeLeft;
  final int total;
  final bool isLowTime;
  final AnimationController pulseController;

  const _CircularTimer({
    required this.timeLeft,
    required this.total,
    required this.isLowTime,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = timeLeft / total;
    final timerColor = isLowTime
        ? context.colors.error
        : fraction > 0.5
        ? context.appColors.success
        : context.appColors.warning;

    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final pulse = isLowTime ? (0.95 + pulseController.value * 0.05) : 1.0;
        return Transform.scale(
          scale: pulse,
          child: SizedBox(
            width: 56.r,
            height: 56.r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 56.r,
                  height: 56.r,
                  child: CustomPaint(
                    painter: _TimerArcPainter(
                      fraction: fraction,
                      color: timerColor,
                      trackColor: context.colors.surfaceContainerHighest,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$timeLeft',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: timerColor,
                        height: 1,
                      ),
                    ),
                    Text(
                      's',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: timerColor.withValues(alpha: 0.7),
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TimerArcPainter extends CustomPainter {
  final double fraction;
  final Color color;
  final Color trackColor;

  const _TimerArcPainter({
    required this.fraction,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = cx - 4;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    const strokeWidth = 4.0;

    // Track
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Arc
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_TimerArcPainter old) =>
      old.fraction != fraction || old.color != color;
}

// ── Answer Option ─────────────────────────────────────────────────────────────

class _AnswerOption extends StatelessWidget {
  final String label;
  final String text;
  final bool isSelected;
  final Duration delay;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.label,
    required this.text,
    required this.isSelected,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            curve: AppCurves.standard,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colors.primaryContainer
                  : context.colors.surfaceContainerLow,
              borderRadius: AppBorders.lg,
              border: Border.all(
                color: isSelected
                    ? context.colors.primary
                    : context.colors.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? AppShadows.subtle : AppShadows.none,
            ),
            child: Row(
              children: [
                // Letter badge
                AnimatedContainer(
                  duration: AppDurations.fast,
                  width: 34.r,
                  height: 34.r,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.surfaceContainerHighest,
                    borderRadius: AppBorders.sm,
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: context.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? context.colors.onPrimary
                            : context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    text,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? context.colors.onPrimaryContainer
                          : context.colors.onSurface,
                    ),
                  ),
                ),
                if (isSelected)
                  Padding(
                    padding: EdgeInsets.only(left: AppSpacing.sm),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: context.colors.primary,
                      size: 20.r,
                    ),
                  ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: delay, duration: AppDurations.normal)
        .slideX(
          begin: 0.06,
          end: 0,
          delay: delay,
          duration: AppDurations.normal,
          curve: AppCurves.emphasized,
        );
  }
}

// ── Bottom Action Bar ─────────────────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final bool isLastQuestion;
  final bool hasSelection;
  final VoidCallback onNext;

  const _BottomActionBar({
    required this.currentIndex,
    required this.totalQuestions,
    required this.isLastQuestion,
    required this.hasSelection,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.sm,
        AppSpacing.pagePadding,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(
            color: context.colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: AppButton(
        label: isLastQuestion ? 'Finish Quiz 🏆' : 'Next Question',
        isFullWidth: true,
        height: ButtonSize.large,
        suffixIcon: isLastQuestion
            ? null
            : Icon(
                Icons.arrow_forward_rounded,
                size: 18.r,
                color: hasSelection
                    ? context.colors.onPrimary
                    : context.colors.onPrimary.withValues(alpha: 0.5),
              ),
        onPressed: hasSelection ? onNext : null,
      ),
    );
  }
}
