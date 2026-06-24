import 'dart:async';

import '../../core/imports/imports.dart';
import '../home/provider/quiz_provider.dart';

class QuizQuestionPage extends StatefulWidget {
  const QuizQuestionPage({super.key});

  @override
  State<QuizQuestionPage> createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends State<QuizQuestionPage> {
  Future<void> _onQuitPressed() async {
    final shouldPop = await context.showAppDialog<bool>(
      builder: (context) => AlertDialog(
        title: const Text('Quit Quiz?'),
        content: const Text(
          'Are you sure you want to quit the quiz? Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: const Text('Quit'),
          ),
        ],
      ),
    );

    if (shouldPop ?? false) {
      if (mounted) {
        context.read<QuizProvider>().quitQuiz();
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();

    if (provider.status == QuizStatus.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final result = provider.buildResult();
          context.go(AppRoutes.quizResult, extra: result);
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.questions.isEmpty ||
        provider.currentIndex >= provider.questions.length) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = provider.questions[provider.currentIndex];
    final totalQuestions = provider.questions.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onQuitPressed();
      },
      child: Scaffold(
        appBar: AppTopBar(
          onPressed: _onQuitPressed,
          titleWidget: Text(
            'Question ${provider.currentIndex + 1} of $totalQuestions',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: AppSpacing.md),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: context.colors.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${provider.score} pts',
                    style: context.textTheme.labelLarge?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              AnimatedContainer(
                duration: 200.microseconds,
                child: LinearProgressIndicator(
                  value: provider.timeLeft / 15,
                  color: context.colors.primary,
                  minHeight: 6,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.pagePadding),
                  child: Column(
                    spacing: AppSpacing.md,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Row: Category & Difficulty, Timer
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: AppSpacing.xxs,
                              children: [
                                Text(
                                  question.category,
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(
                                        color: context.colors.onSurfaceVariant,
                                      ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    question.difficulty.name.toUpperCase(),
                                    style: context.textTheme.labelSmall
                                        ?.copyWith(
                                          color: Colors.green[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: AppSpacing.xs,
                            children: [
                              Icon(
                                Icons.timer,
                                size: 16,
                                color: context.colors.onSurfaceVariant,
                              ),
                              Text(
                                '${provider.timeLeft} s',
                                style: context.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: provider.timeLeft <= 5
                                      ? context.colors.error
                                      : context.colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      Text(
                        question.question,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      
                      const Divider(),
                      
                      Expanded(
                        child: ListView.separated(
                          itemCount: provider.shuffledAnswers.length,
                          separatorBuilder: (_, _) =>
                              AppSpacing.sm.verticalSpace,
                          itemBuilder: (context, index) {
                            final answer = provider.shuffledAnswers[index];
                            final isSelected =
                                provider.selectedAnswer == answer;

                            return InkWell(
                              onTap: () => provider.selectAnswer(answer),
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? context.colors.primaryContainer
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? context.colors.primary
                                        : context.colors.outlineVariant,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Text(
                                  answer,
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(
                                        color: isSelected
                                            ? context.colors.onPrimaryContainer
                                            : context.colors.onSurface,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Next Button
                      AppButton(
                        label: provider.currentIndex < totalQuestions - 1
                            ? 'Next Question'
                            : 'Finish Quiz',
                        isFullWidth: true,
                        onPressed: provider.selectedAnswer == null
                            ? null
                            : () => provider.confirmNext(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
