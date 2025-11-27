import 'package:flutter_riverpod/legacy.dart';

/// Estado del menú para controlar qué grupo está expandido
class MenuState {
  final String? expandedGroupId;

  const MenuState({this.expandedGroupId});

  MenuState copyWith({String? expandedGroupId}) {
    return MenuState(expandedGroupId: expandedGroupId);
  }
}

/// Notifier para gestionar el estado del menú
class MenuStateNotifier extends StateNotifier<MenuState> {
  MenuStateNotifier()
    : super(const MenuState(expandedGroupId: 'home_transactions'));

  /// Alterna el estado de un grupo
  void toggleGroup(String groupId) {
    if (state.expandedGroupId == groupId) {
      // Si el grupo actual está abierto, lo cerramos
      state = MenuState(expandedGroupId: null);
    } else {
      // Abrimos el nuevo grupo (automáticamente cierra cualquier otro)
      state = MenuState(expandedGroupId: groupId);
    }
  }

  /// Establece un grupo específico como expandido
  void setExpandedGroup(String? groupId) {
    state = MenuState(expandedGroupId: groupId);
  }

  /// Verifica si un grupo específico está expandido
  bool isGroupExpanded(String groupId) {
    return state.expandedGroupId == groupId;
  }

  /// Cierra todos los grupos
  void closeAllGroups() {
    state = const MenuState(expandedGroupId: null);
  }
}

/// Provider para el estado del menú
final menuStateProvider = StateNotifierProvider<MenuStateNotifier, MenuState>(
  (ref) => MenuStateNotifier(),
);
