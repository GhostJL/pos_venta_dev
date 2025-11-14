class UserPermission {
  final int userId;
  final int permissionId;
  final DateTime grantedAt;
  final int? grantedBy;

  UserPermission({
    required this.userId,
    required this.permissionId,
    required this.grantedAt,
    this.grantedBy,
  });
}
