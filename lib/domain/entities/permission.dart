
class Permission {
  final int? id;
  final String name;
  final String code;
  final String? description;
  final String module;
  final bool isActive;

  Permission({
    this.id,
    required this.name,
    required this.code,
    this.description,
    required this.module,
    this.isActive = true,
  });
}
