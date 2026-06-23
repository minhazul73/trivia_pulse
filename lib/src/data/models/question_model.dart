import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

enum QuestionType { multiple, boolean, any }

enum QuestionDifficulty { easy, medium, hard, any }

class QuestionModel extends Equatable {
  final QuestionType type;
  final QuestionDifficulty difficulty;
  final String category;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;

  const QuestionModel({
    required this.type,
    required this.difficulty,
    required this.category,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
  });

  QuestionModel copyWith({
    QuestionType? type,
    QuestionDifficulty? difficulty,
    String? category,
    String? question,
    String? correctAnswer,
    List<String>? incorrectAnswers,
  }) {
    return QuestionModel(
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      question: question ?? this.question,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
    );
  }

  @override
  List<Object?> get props => [
    type,
    difficulty,
    category,
    question,
    correctAnswer,
    incorrectAnswers,
  ];

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'difficulty': difficulty,
      'category': category,
      'question': question,
      'correct_answer': correctAnswer,
      'incorrect_answers': incorrectAnswers,
    };
  }

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      type: json['type'],
      difficulty: json['difficulty'],
      category: json['category'],
      question: json['question'],
      correctAnswer: json['correct_answer'],
      incorrectAnswers: List<String>.from(json['incorrect_answers']),
    );
  }

  @override
  String toString() {
    return '''QuestionModel(type: ${type.name}, difficulty: ${difficulty.name}, category: $category, question: $question, correctAnswer: $correctAnswer, incorrectAnswers: $incorrectAnswers)''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuestionModel &&
        other.type == type &&
        other.difficulty == difficulty &&
        other.category == category &&
        other.question == question &&
        other.correctAnswer == correctAnswer &&
        listEquals(other.incorrectAnswers, incorrectAnswers);
  }

  @override
  int get hashCode {
    return type.hashCode ^
        difficulty.hashCode ^
        category.hashCode ^
        question.hashCode ^
        correctAnswer.hashCode ^
        incorrectAnswers.hashCode;
  }
}
