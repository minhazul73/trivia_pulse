import '../../core/imports/imports.dart';
import 'provider/quiz_provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.pagePadding,
            AppSpacing.pagePadding,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Text(
                'Test your knowledge!',
                style: context.textTheme.headlineSmall,
              ),
              Expanded(
                child: SkeletonWrapper(
                  isLoading: quizProvider.isLoading,
                  child: ListView.separated(
                    itemCount: quizProvider.categories.length,
                    itemBuilder: ((context, index) {
                      final category = quizProvider.categories[index];
                      final count = category.questionCount?.totalQuestionCount;
                      return AppCard(
                        trailing: const Icon(Icons.arrow_forward_ios),
                        title: category.name,
                        subtitle: count != null
                            ? '$count questions'
                            : 'Loading...',
                        onTap: () => context.push(
                          AppRoutes.quizCustomization,
                          extra: {'category': category},
                        ),
                      );
                    }),
                    separatorBuilder: (context, index) {
                      return AppSpacing.itemGap.verticalSpace;
                    },
                  ),
                ),
              ),
              // AppSpacing.xxxs.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
