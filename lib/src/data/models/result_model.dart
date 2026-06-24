import 'package:equatable/equatable.dart';

import 'question_model.dart';

class ResultModel extends Equatable {
  final String? id; // Firestore document ID
  final int totalQuestions;
  final int correctCount;
  final int score;
  final List<String> selectedAnswers; // null = skipped / timed-out
  final List<QuestionModel> questions;
  final String categoryName;
  final DateTime timestamp;

  const ResultModel({
    this.id,
    required this.totalQuestions,
    required this.correctCount,
    required this.score,
    required this.selectedAnswers,
    required this.questions,
    required this.categoryName,
    required this.timestamp,
  });
  
  @override
  List<Object?> get props => [
    id,
    totalQuestions,
    correctCount,
    score,
    selectedAnswers,
    questions,
    categoryName,
    timestamp,
  ];

  /// Create a new Result from the current state (e.g. when quiz ends)
  ResultModel copyWith({
    String? id,
    int? totalQuestions,
    int? correctCount,
    int? score,
    List<String>? selectedAnswers,
    List<QuestionModel>? questions,
    String? categoryName,
    DateTime? timestamp,
  }) {
    return ResultModel(
      id: id ?? this.id,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctCount: correctCount ?? this.correctCount,
      score: score ?? this.score,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      questions: questions ?? this.questions,
      categoryName: categoryName ?? this.categoryName,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Helper for Firestore toJson
  Map<String, dynamic> toJson() {
    return {
      'totalQuestions': totalQuestions,
      'correctCount': correctCount,
      'score': score,
      'selectedAnswers': selectedAnswers,
      'categoryName': categoryName,
      'timestamp': timestamp,
    };
  }

  // Helper for Firestore fromJson
  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      id: json['id'],
      totalQuestions: json['totalQuestions'],
      correctCount: json['correctCount'],
      score: json['score'],
      selectedAnswers: (json['selectedAnswers'] as List<dynamic>?)
          ?.map((x) => x as String)
          .toList() ?? [],
      questions: (json['questions'] as List<dynamic>?)
          ?.map((x) => QuestionModel.fromJson(x as Map<String, dynamic>))
          .toList() ?? [],
      categoryName: json['categoryName'],
      timestamp: json['timestamp'].toDate(),
    );
  }
}