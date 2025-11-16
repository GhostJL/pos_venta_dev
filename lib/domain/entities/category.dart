class Category {
  final int? id;
  final String name;
  final String code;
  final int departmentId;
  final int? parentCategoryId;
  final String? description;
  final int displayOrder;
  final bool isActive;

  Category({
    this.id,
    required this.name,
    required this.code,
    required this.departmentId,
    this.parentCategoryId,
    this.description,
    this.displayOrder = 0,
    this.isActive = true,
  });

  //copyWith method
  Category copyWith({
    int? id,
    String? name,
    String? code,
    int? departmentId,
    int? parentCategoryId,
    String? description,
    int? displayOrder,
    bool? isActive,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      departmentId: departmentId ?? this.departmentId,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      description: description ?? this.description,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
    );
  }
}
