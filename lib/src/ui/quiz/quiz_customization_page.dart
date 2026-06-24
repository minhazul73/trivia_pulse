import '../../core/imports/imports.dart';
import '../../core/shared/widgets/app_dropdown_field.dart';
import '../../data/models/category_model.dart';
import '../../data/models/question_model.dart';
import '../home/provider/quiz_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();

    return Scaffold(
      appBar: AppTopBar(title: widget.category.name),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            spacing: AppSpacing.md,
            crossAxisAlignment: .start,
            children: [
              Text(
                'Customize your quiz',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    '${widget.category.questionCount?.totalQuestionCount ?? 0} Questions Available',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.primary,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      _DifficultyChip(
                        label: 'Easy,',
                        count:
                            widget
                                .category
                                .questionCount
                                ?.totalEasyQuestionCount ??
                            0,
                      ),
                      _DifficultyChip(
                        label: 'Medium,',
                        count:
                            widget
                                .category
                                .questionCount
                                ?.totalMediumQuestionCount ??
                            0,
                      ),
                      _DifficultyChip(
                        label: 'Hard',
                        count:
                            widget
                                .category
                                .questionCount
                                ?.totalHardQuestionCount ??
                            0,
                      ),
                    ],
                  ),
                ],
              ),
              // AppSpacing.xxxs.verticalSpace,
              Text(
                'Tailor your trivia experience by selecting the number of questions, type, and difficulty level.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              Column(
                spacing: AppSpacing.sm,
                children: [
                  Row(
                    spacing: AppSpacing.md,
                    children: [
                      Expanded(
                        child: AppDropDownField<int>(
                          items: const [5, 10, 20, 30, 40, 50],
                          value: _amount,
                          label: 'Question Amount',
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _amount = value;
                              });
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: AppDropDownField<String>(
                          items: QuestionType.values
                              .map((e) => e.name)
                              .toList(),
                          value: QuestionType.any.name,
                          label: 'Question Type',
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _type = QuestionType.values.firstWhere(
                                  (e) => e.name == value,
                                );
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  AppDropDownField<String>(
                    items: QuestionDifficulty.values
                        .map((e) => e.name)
                        .toList(),
                    value: QuestionDifficulty.any.name,
                    label: 'Question Difficulty',
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _difficulty = QuestionDifficulty.values.firstWhere(
                            (e) => e.name == value,
                          );
                        });
                      }
                    },
                  ),
                ],
              ),
              const Spacer(),
              Column(
                spacing: AppSpacing.xs,
                children: [
                  Text(
                    'Ready to test your knowledge?',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  AppButton(
                    label: 'Start Quiz',
                    isLoading: quizProvider.isLoading,
                    isFullWidth: true,
                    onPressed: quizProvider.isLoading ? null : () async {
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
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String label;
  final int count;

  const _DifficultyChip({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: context.textTheme.bodySmall,
        children: [
          TextSpan(
            text: '$count ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: label),
        ],
      ),
    );
  }
}
