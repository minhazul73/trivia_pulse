import 'dart:async';

import '../../../core/imports/imports.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/question_model.dart';
import '../../../data/repositories/quiz/quiz_repository.dart';

enum QuizStatus { idle, active, finished }

class QuizProvider extends ChangeNotifier {
  final QuizRepository _repository;
  QuizProvider({required QuizRepository repository}) : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  List<QuestionModel> _questions = [];
  List<QuestionModel> get questions => _questions;

  final Map<int, CategoryQuestionCountModel> _categoryCounts = {};
  Map<int, CategoryQuestionCountModel> get categoryCounts => _categoryCounts;

  // --- Quiz State ---
  QuizStatus _status = QuizStatus.idle;
  QuizStatus get status => _status;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  int _score = 0;
  int get score => _score;

  int _timeLeft = 15;
  int get timeLeft => _timeLeft;

  String? _selectedAnswer;
  String? get selectedAnswer => _selectedAnswer;

  List<String> _shuffledAnswers = [];
  List<String> get shuffledAnswers => _shuffledAnswers;

  Timer? _timer;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> getQuestions({
    required BuildContext context,
    required int categoryId,
    required int amount,
    required QuestionType type,
    required QuestionDifficulty difficulty,
  }) async {
    _setLoading(true);
    final result = await _repository.getQuestions(
      categoryId: categoryId,
      amount: amount,
      type: type,
      difficulty: difficulty,
    );
    result.fold(
      (failure) {
        _setLoading(false);
        showGlobalToast(message: failure.message, status: 'error');
      },
      (questions) {
        _questions = questions;
        _setLoading(false);
        if (_questions.isEmpty) {
          showGlobalToast(
            message:
                'Something went wrong in the server, try different customization or try again later',
            status: 'error',
          );
          return;
        }
        if (context.mounted) {
          startQuiz();
          context.pushReplacement(AppRoutes.quizQuestion);
        }
      },
    );
  }

  // --- Quiz Methods ---
  void startQuiz() {
    _status = QuizStatus.active;
    _currentIndex = 0;
    _score = 0;
    _loadQuestionData();
  }

  void _loadQuestionData() {
    if (_currentIndex >= _questions.length) return;

    final question = _questions[_currentIndex];
    _shuffledAnswers = [question.correctAnswer, ...question.incorrectAnswers];
    _shuffledAnswers.shuffle();
    _selectedAnswer = null;
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timeLeft = 15;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_status != QuizStatus.active) {
        timer.cancel();
        return;
      }

      if (_timeLeft > 0) {
        _timeLeft--;
        notifyListeners();
      } else {
        _timer?.cancel();
        _goToNextQuestion();
      }
    });
  }

  void selectAnswer(String answer) {
    _selectedAnswer = answer;
    notifyListeners();
  }

  void confirmNext() {
    _timer?.cancel();
    _goToNextQuestion();
  }

  void _goToNextQuestion() {
    if (_status != QuizStatus.active || _currentIndex >= _questions.length) return;

    final question = _questions[_currentIndex];
    if (_selectedAnswer == question.correctAnswer) {
      _score += 10;
    }

    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _loadQuestionData();
    } else {
      _timer?.cancel();
      _status = QuizStatus.finished;
      notifyListeners();

      showGlobalToast(
        message: 'Quiz Finished! Your score: $_score',
        status: 'success',
      );
    }
  }

  void quitQuiz() {
    _timer?.cancel();
    _status = QuizStatus.idle;
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    notifyListeners();
  }



  Future<void> getCategories() async {
    _setLoading(true);
    final result = await _repository.getCategories();

    result.fold(
      (failure) {
        _setLoading(false);
        showGlobalToast(message: failure.message, status: 'error');
      },
      (categories) {
        _categories = categories;
        _setLoading(false);
        _loadAllCategoryCounts();
        notifyListeners();
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

          final index = _categories.indexWhere((c) => c.id == category.id);
          if (index != -1) {
            _categories[index] = category.copyWith(questionCount: count);
          }

          AppLogger.info(
            'Count for category ${category.id}: ${count.toJson()}',
          );
          notifyListeners();
        },
      );

      // Small delay to prevent rate limiting from OpenTDB
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }
}
