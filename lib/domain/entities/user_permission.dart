class UserPermission {
  final int? id;
  final int userId;
  final int permissionId;
  final DateTime grantedAt;
  final int? grantedBy;

  UserPermission({
    this.id,
    required this.userId,
    required this.permissionId,
    required this.grantedAt,
    this.grantedBy,
  });
}
