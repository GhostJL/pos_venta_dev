class Brand {
  final int? id;
  final String name;
  final String code;
  final bool isActive;

  Brand({
    this.id,
    required this.name,
    required this.code,
    this.isActive = true,
  });

   Brand copyWith({
    int? id,
    String? name,
    String? code,
    bool? isActive,
  }) {
    return Brand(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      isActive: isActive ?? this.isActive,
    );
  }
}
