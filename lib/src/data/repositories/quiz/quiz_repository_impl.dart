import '../../../core/imports/imports.dart';
import '../../models/category_model.dart';
import '../../models/question_model.dart';
import 'quiz_repository.dart';

class QuizRepositoryImpl implements QuizRepository {
  final _apiClient = DioService.instance;

  @override
  FutureEither<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get('/api_category.php');
    return response.fold(
      (failure) {
        AppLogger.error('Failed to fetch categories: $failure');
        return left(failure);
      },
      (response) {
        final data = CategoryModel.fromJsonList(response.data['trivia_categories']);
        AppLogger.success('Categories fetched successfully: ${data.toString()}');
        return right(data);
      },
    );
  }
  @override
  FutureEither<int> getCategoryQuestionCount(int categoryId) async {
    final response = await _apiClient.get('/api_count.php', queryParameters: {
      'category': categoryId,
    });
    return response.fold(
      (failure) {
        AppLogger.error('Failed to fetch category count: $failure');
        return left(failure);
      },
      (response) {
        final data = response.data['category_question_count']['total_question_count'] as int;
        return right(data);
      },
    );
  }

  @override
  FutureEither<List<QuestionModel>> getQuestions({
    required int categoryId,
    required int amount,
    required QuestionType type,
    required QuestionDifficulty difficulty,
  }) {
    // TODO: implement getQuestions
    throw UnimplementedError();
  }
}
  