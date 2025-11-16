import 'package:myapp/domain/entities/category.dart';

class CategoryModel extends Category {
  CategoryModel({
    super.id,
    required super.name,
    required super.code,
    required super.departmentId,
    super.parentCategoryId,
    super.description,
    super.displayOrder,
    super.isActive,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      departmentId: map['department_id'],
      parentCategoryId: map['parent_category_id'],
      description: map['description'],
      displayOrder: map['display_order'],
      isActive: map['is_active'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'department_id': departmentId,
      'parent_category_id': parentCategoryId,
      'description': description,
      'display_order': displayOrder,
      'is_active': isActive ? 1 : 0,
    };
  }
}
