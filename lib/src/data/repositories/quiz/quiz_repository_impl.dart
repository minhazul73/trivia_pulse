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
  FutureEither<CategoryQuestionCountModel> getCategoryQuestionCount(int categoryId) async {
    final response = await _apiClient.get('/api_count.php', queryParameters: {
      'category': categoryId,
    });
    return response.fold(
      (failure) {
        AppLogger.error('Failed to fetch category count: $failure');
        return left(failure);
      },
      (response) {
        final data = CategoryQuestionCountModel.fromJson(response.data['category_question_count']);
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
  }) async {
    // https://opentdb.com/api.php?amount=10&category=22&difficulty=medium&type=multiple
    final response = await _apiClient.get(
      '/api.php',
      queryParameters: {
        'amount': amount,
        'category': categoryId,
        if (difficulty != QuestionDifficulty.any) 'difficulty': difficulty.name,
        if (type != QuestionType.any) 'type': type.name,
      },
    );
    return response.fold(
      (failure) {
        AppLogger.error('Failed to fetch questions: $failure');
        return left(failure);
      },
      (response) {
        final data = QuestionModel.fromJsonList(response.data['results']);
        AppLogger.success('Questions fetched successfully: ${data.toString()}');
        return right(data);
      },
    );
  }
}
  