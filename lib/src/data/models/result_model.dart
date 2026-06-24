import 'package:equatable/equatable.dart';

/// Lightweight result record stored in Hive and Firestore.
/// Questions are intentionally omitted to save storage space.
class ResultModel extends Equatable {
  final String? id; // Firestore document ID / Hive key
  final int totalQuestions;
  final int correctCount;
  final int score;
  final List<String> selectedAnswers;
  final String categoryName;
  final String difficulty; // 'any' | 'easy' | 'medium' | 'hard'
  final String questionType; // 'any' | 'multiple' | 'boolean'
  final DateTime timestamp;

  const ResultModel({
    this.id,
    required this.totalQuestions,
    required this.correctCount,
    required this.score,
    required this.selectedAnswers,
    required this.categoryName,
    required this.difficulty,
    required this.questionType,
    required this.timestamp,
  });

  int get skippedCount =>
      selectedAnswers.where((a) => a.isEmpty).length;

  int get wrongCount => totalQuestions - correctCount - skippedCount;

  double get accuracy =>
      totalQuestions == 0 ? 0 : (correctCount / totalQuestions) * 100;

  @override
  List<Object?> get props => [
    id,
    totalQuestions,
    correctCount,
    score,
    selectedAnswers,
    categoryName,
    difficulty,
    questionType,
    timestamp,
  ];

  ResultModel copyWith({
    String? id,
    int? totalQuestions,
    int? correctCount,
    int? score,
    List<String>? selectedAnswers,
    String? categoryName,
    String? difficulty,
    String? questionType,
    DateTime? timestamp,
  }) {
    return ResultModel(
      id: id ?? this.id,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctCount: correctCount ?? this.correctCount,
      score: score ?? this.score,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      categoryName: categoryName ?? this.categoryName,
      difficulty: difficulty ?? this.difficulty,
      questionType: questionType ?? this.questionType,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // ── Serialization ────────────────────────────────────────────────────────

  /// For Firestore — timestamp stays as DateTime (Firestore SDK handles conversion).
  Map<String, dynamic> toJson() {
    return {
      'totalQuestions': totalQuestions,
      'correctCount': correctCount,
      'score': score,
      'selectedAnswers': selectedAnswers,
      'categoryName': categoryName,
      'difficulty': difficulty,
      'questionType': questionType,
      'timestamp': timestamp,
    };
  }

  /// For Hive — timestamp as ISO-8601 string (Hive [box<dynamic>] can't store DateTime directly).
  Map<String, dynamic> toStorageMap() {
    return {
      if (id != null) 'id': id,
      'totalQuestions': totalQuestions,
      'correctCount': correctCount,
      'score': score,
      'selectedAnswers': List<String>.from(selectedAnswers),
      'categoryName': categoryName,
      'difficulty': difficulty,
      'questionType': questionType,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// From Firestore — caller must have already converted Timestamp → DateTime.
  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      id: json['id'] as String?,
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      correctCount: (json['correctCount'] as num).toInt(),
      score: (json['score'] as num).toInt(),
      selectedAnswers: (json['selectedAnswers'] as List<dynamic>?)
              ?.map((x) => x as String)
              .toList() ??
          [],
      categoryName: json['categoryName'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'any',
      questionType: json['questionType'] as String? ?? 'any',
      timestamp: json['timestamp'] as DateTime,
    );
  }

  /// From Hive storage — timestamp is ISO-8601 string.
  factory ResultModel.fromStorageMap(Map<String, dynamic> json) {
    return ResultModel(
      id: json['id'] as String?,
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      correctCount: (json['correctCount'] as num).toInt(),
      score: (json['score'] as num).toInt(),
      selectedAnswers: (json['selectedAnswers'] as List<dynamic>?)
              ?.map((x) => x as String)
              .toList() ??
          [],
      categoryName: json['categoryName'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'any',
      questionType: json['questionType'] as String? ?? 'any',
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}