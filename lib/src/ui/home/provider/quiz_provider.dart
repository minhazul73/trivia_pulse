import '../../../core/imports/imports.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/quiz/quiz_repository.dart';

class QuizProvider extends ChangeNotifier {
  final QuizRepository _repository;
  QuizProvider({required QuizRepository repository}) : _repository = repository;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<CategoryModel> _categories = [];

  List<CategoryModel> get categories => _categories;

  final Map<int, int> _categoryCounts = {};

  Map<int, int> get categoryCounts => _categoryCounts;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> getCategories() async {
    _setLoading(true);
    final result = await _repository.getCategories();
    
    _setLoading(false);
    result.fold(
      (failure) {
        showGlobalToast(message: failure.message, status: 'error');
      },
      (categories) {
        _categories = categories;
        _loadAllCategoryCounts();
      },
    );
  }

  Future<void> _loadAllCategoryCounts() async {
    for (final category in _categories) {
      if (_categoryCounts.containsKey(category.id)) continue;
      
      final result = await _repository.getCategoryQuestionCount(category.id);
      result.fold(
        (failure) {
          AppLogger.error('Failed to fetch count for category ${category.id}');
        },
        (count) {
          _categoryCounts[category.id] = count;
          notifyListeners();
        },
      );
      // Small delay to prevent rate limiting from OpenTDB
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }
}