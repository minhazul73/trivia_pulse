import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final int id;
  final String name;
  final CategoryQuestionCountModel? questionCount;

  const CategoryModel({
    required this.id,
    required this.name,
    this.questionCount,
  });

  CategoryModel copyWith({
    int? id,
    String? name,
    CategoryQuestionCountModel? questionCount,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      questionCount: questionCount ?? this.questionCount,
    );
  }

  @override
  List<Object?> get props => [id, name, questionCount];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (questionCount != null) 'category_question_count': questionCount!.toJson(),
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      questionCount: json['category_question_count'] != null
          ? CategoryQuestionCountModel.fromJson(json['category_question_count'])
          : null,
    );
  }

  // fromJsonList static method
  static List<CategoryModel> fromJsonList(List<dynamic> json) {
    return json.map((x) => CategoryModel.fromJson(x)).toList();
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, questionCount: $questionCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoryModel &&
        other.id == id &&
        other.name == name &&
        other.questionCount == questionCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ questionCount.hashCode;
  }
}

class CategoryQuestionCountModel extends Equatable {
  final int totalQuestionCount;
  final int totalEasyQuestionCount;
  final int totalMediumQuestionCount;
  final int totalHardQuestionCount;

  const CategoryQuestionCountModel({
    required this.totalQuestionCount,
    required this.totalEasyQuestionCount,
    required this.totalMediumQuestionCount,
    required this.totalHardQuestionCount,
  });

  CategoryQuestionCountModel copyWith({
    int? totalQuestionCount,
    int? totalEasyQuestionCount,
    int? totalMediumQuestionCount,
    int? totalHardQuestionCount,
  }) {
    return CategoryQuestionCountModel(
      totalQuestionCount: totalQuestionCount ?? this.totalQuestionCount,
      totalEasyQuestionCount: totalEasyQuestionCount ?? this.totalEasyQuestionCount,
      totalMediumQuestionCount: totalMediumQuestionCount ?? this.totalMediumQuestionCount,
      totalHardQuestionCount: totalHardQuestionCount ?? this.totalHardQuestionCount,
    );
  }

  @override
  List<Object?> get props => [
    totalQuestionCount,
    totalEasyQuestionCount,
    totalMediumQuestionCount,
    totalHardQuestionCount,
  ];

  Map<String, dynamic> toJson() {
    return {
      'total_question_count': totalQuestionCount,
      'total_easy_question_count': totalEasyQuestionCount,
      'total_medium_question_count': totalMediumQuestionCount,
      'total_hard_question_count': totalHardQuestionCount,
    };
  }

  factory CategoryQuestionCountModel.fromJson(Map<String, dynamic> json) {
    return CategoryQuestionCountModel(
      totalQuestionCount: json['total_question_count'],
      totalEasyQuestionCount: json['total_easy_question_count'],
      totalMediumQuestionCount: json['total_medium_question_count'],
      totalHardQuestionCount: json['total_hard_question_count'],
    );
  }
}