// ignore_for_file: prefer_relative_imports
import '../../core/imports/imports.dart';
import '../../data/models/result_model.dart';
import '../../ui/auth/providers/session_provider.dart';
import '../../ui/profile/provider/result_history_provider.dart';
import 'provider/quiz_provider.dart';

class QuizResultPage extends StatefulWidget {
  final ResultModel result;

  const QuizResultPage({super.key, required this.result});

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage> {
  @override
  void initState() {
    super.initState();
    // Save the result once, after the first frame, so the provider tree is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final session = context.read<SessionProvider>();
      final uid = session.user?.id;
      if (uid != null) {
        context.read<ResultHistoryProvider>().init(
          uid: uid,
          displayName: session.user?.name,
          photoUrl: session.user?.photoUrl,
        ).then((_) {
          if (mounted) {
            context
                .read<ResultHistoryProvider>()
                .saveResult(widget.result);
          }
        });
      }
    });
  }

  ResultModel get result => widget.result;

  @override
  Widget build(BuildContext context) {
    final accuracy = result.totalQuestions == 0
        ? 0.0
        : result.correctCount / result.totalQuestions;

    final appColors = context.appColors;
    // Questions are read from the provider — they stay in memory while this
    // page is showing. They're NOT stored on ResultModel to save space.
    final questions = context.read<QuizProvider>().questions;

    final (scoreColor, scoreLabel, scoreIcon) = accuracy >= 0.7
        ? (appColors.success, 'Excellent! 🏆', Icons.emoji_events_rounded)
        : accuracy >= 0.5
        ? (appColors.warning, 'Good Job! 👍', Icons.thumb_up_rounded)
        : (context.colors.error, 'Keep Practicing 💪', Icons.refresh_rounded);

    final skippedCount =
        result.selectedAnswers.where((a) => a.isEmpty).length;
    final wrongCount =
        result.totalQuestions - result.correctCount - skippedCount;

    return Scaffold(
      appBar: const AppTopBar(title: 'Quiz Results', centerTitle: true),
      body: ListView(
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.xl,
          horizontal: AppSpacing.pagePadding,
        ),
        children: [
          // ── Animated celebration icon ──────────────────────────────────
          Center(
            child: Container(
              width: 96.r,
              height: 96.r,
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(scoreIcon, color: scoreColor, size: 48.r),
            )
                .animate()
                .scale(
                  begin: Offset.zero,
                  end: const Offset(1, 1),
                  duration: AppDurations.medium,
                  curve: AppCurves.emphasized,
                )
                .fadeIn(duration: AppDurations.fast),
          ),
          SizedBox(height: AppSpacing.md),

          // ── Score label ────────────────────────────────────────────────
          Center(
            child: Text(
              scoreLabel,
              style: context.textTheme.headlineSmall?.copyWith(
                color: scoreColor,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(
                  delay: const Duration(milliseconds: 200),
                  duration: AppDurations.normal,
                ),
          ),
          SizedBox(height: AppSpacing.lg),

          // ── Score circle ───────────────────────────────────────────────
          Center(
            child: _ScoreCircle(result: result, color: scoreColor)
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 300),
                  duration: AppDurations.normal,
                )
                .slideY(begin: 0.2, end: 0),
          ),
          SizedBox(height: AppSpacing.lg),

          // ── Stat pills ─────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatPill(
                icon: Icons.check_circle_rounded,
                label: 'Correct',
                value: '${result.correctCount}',
                color: appColors.success,
              ),
              _StatPill(
                icon: Icons.cancel_rounded,
                label: 'Wrong',
                value: '$wrongCount',
                color: context.colors.error,
              ),
              _StatPill(
                icon: Icons.timer_off_rounded,
                label: 'Skipped',
                value: '$skippedCount',
                color: context.colors.onSurfaceVariant,
              ),
            ],
          ).animate().fadeIn(
                delay: const Duration(milliseconds: 400),
                duration: AppDurations.normal,
              ),
          SizedBox(height: AppSpacing.xs),

          // ── Share button ───────────────────────────────────────────────
          TextButton.icon(
            onPressed: () => _shareScore(context),
            icon: const Icon(Icons.share_rounded),
            label: const Text('Share your score'),
          ),
          SizedBox(height: AppSpacing.md),

          // ── Answer Review header ───────────────────────────────────────
          Text(
            'Answer Review',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.sm),

          // ── Answer review cards ────────────────────────────────────────
          if (questions.isNotEmpty)
          ...List.generate(questions.length, (i) {
            final q = questions[i];
            final selected = result.selectedAnswers[i];
            final isSkipped = selected.isEmpty;
            final isCorrect = !isSkipped && selected == q.correctAnswer;

            final cardBorderColor = isSkipped
                ? context.colors.outlineVariant
                : isCorrect
                ? appColors.success.withValues(alpha: 0.5)
                : context.colors.error.withValues(alpha: 0.5);

            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: AppBorders.card,
                  side: BorderSide(color: cardBorderColor),
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.ms),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question header row
                      Row(
                        children: [
                          Icon(
                            isSkipped
                                ? Icons.timer_off_outlined
                                : isCorrect
                                ? Icons.check_circle_outline_rounded
                                : Icons.cancel_outlined,
                            color: isSkipped
                                ? context.colors.onSurfaceVariant
                                : isCorrect
                                ? appColors.success
                                : context.colors.error,
                            size: 18.r,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            'Q${i + 1}',
                            style: context.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          _ReviewBadge(
                            label: isSkipped
                                ? 'Skipped'
                                : isCorrect
                                ? '+10 pts'
                                : 'Wrong',
                            color: isSkipped
                                ? context.colors.onSurfaceVariant
                                : isCorrect
                                ? appColors.success
                                : context.colors.error,
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),

                      // Question text
                      Text(
                        q.question,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),

                      // User's wrong answer (only shown when wrong)
                      if (!isSkipped && !isCorrect) ...[
                        _AnswerRow(
                          prefix: 'Your answer',
                          text: selected,
                          color: context.colors.error,
                        ),
                        SizedBox(height: AppSpacing.xxs),
                      ],

                      // Correct answer
                      _AnswerRow(
                        prefix: 'Correct',
                        text: q.correctAnswer,
                        color: appColors.success,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(
                    delay: Duration(milliseconds: 500 + i * 60),
                    duration: AppDurations.normal,
                  ),
            );
          }),

          // ── Action buttons ─────────────────────────────────────────────
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Home',
                  variant: ButtonVariant.outline,
                  prefixIcon: Icon(Icons.home_outlined, size: 18.r),
                  isFullWidth: true,
                  onPressed: () {
                    context.read<QuizProvider>().quitQuiz();
                    context.go(AppRoutes.bottomNav);
                  },
                ),
              ),
              SizedBox(width: AppSpacing.ms),
              Expanded(
                child: AppButton(
                  label: 'Play Again',
                  variant: ButtonVariant.primary,
                  prefixIcon: Icon(Icons.replay_rounded, size: 18.r),
                  isFullWidth: true,
                  onPressed: () {
                    context.read<QuizProvider>().startQuiz();
                    context.go(AppRoutes.quizQuestion);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  void _shareScore(BuildContext context) {
    final accuracy = result.totalQuestions == 0
        ? 0.0
        : result.correctCount / result.totalQuestions;
    final pct = (accuracy * 100).round();
    SharePlus.instance.share(
      ShareParams(
        text:
            'I scored ${result.score} pts ($pct% accuracy) on "${result.categoryName}" in Trivia Pulse! Can you beat me? 🎯',
      ),
    );
  }
}

// ── Score Circle ──────────────────────────────────────────────────────────────

class _ScoreCircle extends StatelessWidget {
  final ResultModel result;
  final Color color;

  const _ScoreCircle({required this.result, required this.color});

  @override
  Widget build(BuildContext context) {
    final accuracy = result.totalQuestions == 0
        ? 0.0
        : result.correctCount / result.totalQuestions;

    return SizedBox(
      width: 140.r,
      height: 140.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 140.r,
            height: 140.r,
            child: CircularProgressIndicator(
              value: accuracy,
              strokeWidth: 10.r,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${result.correctCount}',
                style: context.textTheme.displaySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'of ${result.totalQuestions}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Stat Pill ─────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppBorders.md,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22.r),
          SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Review Badge ──────────────────────────────────────────────────────────────

class _ReviewBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _ReviewBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppBorders.full,
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── Answer Row ────────────────────────────────────────────────────────────────

class _AnswerRow extends StatelessWidget {
  final String prefix;
  final String text;
  final Color color;

  const _AnswerRow({
    required this.prefix,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$prefix: ',
          style: context.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.labelSmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
