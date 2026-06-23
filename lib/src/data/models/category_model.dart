import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final int id;
  final String name;

  const CategoryModel({
    required this.id,
    required this.name,
  });

  CategoryModel copyWith({
    int? id,
    String? name,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  List<Object?> get props => [id, name];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
    );
  }

  // fromJsonList static method
  static List<CategoryModel> fromJsonList(List<dynamic> json) {
    return json.map((x) => CategoryModel.fromJson(x)).toList();
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoryModel &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode;
  }
}