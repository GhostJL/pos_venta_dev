class Department {
  final int? id;
  final String name;
  final String code;
  final String? description;
  final int displayOrder;
  final bool isActive;

  Department({
    this.id,
    required this.name,
    required this.code,
    this.description,
    this.displayOrder = 0,
    this.isActive = true,
  });
}
