import '../../../core/imports/imports.dart';
import '../../models/category_model.dart';
import '../../models/question_model.dart';

abstract class QuizRepository {
  /// Get all quiz categories
  FutureEither<List<CategoryModel>> getCategories();

  /// Get question count for a specific category
  FutureEither<CategoryQuestionCountModel> getCategoryQuestionCount(int categoryId);

  /// Get questions based on category, amount, and difficulty
  FutureEither<List<QuestionModel>> getQuestions({
    required int categoryId,
    required int amount,
    required QuestionType type,
    required QuestionDifficulty difficulty,
  });
}