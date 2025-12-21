import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/domain/entities/user_permission.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/providers/warehouse_providers.dart';

class CreateAccountState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  CreateAccountState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  CreateAccountState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return CreateAccountState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class CreateAccountNotifier extends Notifier<CreateAccountState> {
  @override
  CreateAccountState build() {
    return CreateAccountState();
  }

  Future<void> createAccount({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    required String warehouseName,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      // 0. Security check: Ensure no users exist
      final hasUsers = await ref.read(hasUsersUseCaseProvider).call();
      if (hasUsers) {
        throw Exception(
          'Ya existe un usuario administrador. No se pueden crear más cuentas de este tipo.',
        );
      }

      // 1. Create User Entity
      final newUser = User(
        id: 0, // ID will be assigned by DB
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: UserRole.administrador,
        isActive: true,
        onboardingCompleted: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 2. Save User to DB
      final userRepository = ref.read(userRepositoryProvider);
      await userRepository.addUser(newUser, password: password);

      // 3. Login to get the assigned ID and set auth state
      await ref.read(authProvider.notifier).login(username, password);

      final authState = ref.read(authProvider);
      if (authState.status == AuthStatus.authenticated &&
          authState.user != null) {
        final userId = authState.user!.id;

        // 4. Assign All Permissions (since it's an admin)
        final permissionRepository = ref.read(permissionRepositoryProvider);
        final userPermissionRepository = ref.read(
          userPermissionRepositoryProvider,
        );

        final allPermissions = await permissionRepository.getPermissions();

        for (final permission in allPermissions) {
          await userPermissionRepository.addUserPermission(
            UserPermission(
              userId: userId!,
              permissionId: permission.id!,
              grantedAt: DateTime.now(),
              grantedBy: userId, // Self-granted as first admin
            ),
          );
        }

        // 5. Create Default Warehouse
        final createWarehouse = ref.read(createWarehouseProvider);
        final newWarehouse = Warehouse(
          name: warehouseName,
          code: 'MAIN-001', // Default code
          address: 'Dirección Principal', // Default placeholder
          isMain: true,
          isActive: true,
        );

        await createWarehouse.call(newWarehouse);

        // 6. Invalidate warehouse provider to refresh the list in other screens
        ref.invalidate(warehouseProvider);
      }

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final createAccountProvider =
    NotifierProvider<CreateAccountNotifier, CreateAccountState>(
      CreateAccountNotifier.new,
    );
