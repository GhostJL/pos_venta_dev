import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'menu_state_provider.g.dart';

/// Estado del menú para controlar qué grupo está expandido
class MenuStateData {
  final String? expandedGroupId;

  const MenuStateData({this.expandedGroupId});

  MenuStateData copyWith({String? expandedGroupId}) {
    return MenuStateData(expandedGroupId: expandedGroupId);
  }
}

/// Notifier para gestionar el estado del menú
@riverpod
class MenuState extends _$MenuState {
  @override
  MenuStateData build() =>
      const MenuStateData(expandedGroupId: 'daily_operations');

  /// Alterna el estado de un grupo
  void toggleGroup(String groupId) {
    if (state.expandedGroupId == groupId) {
      // Si el grupo actual está abierto, lo cerramos
      state = const MenuStateData(expandedGroupId: null);
    } else {
      // Abrimos el nuevo grupo (automáticamente cierra cualquier otro)
      state = MenuStateData(expandedGroupId: groupId);
    }
  }

  /// Establece un grupo específico como expandido
  void setExpandedGroup(String? groupId) {
    state = MenuStateData(expandedGroupId: groupId);
  }

  /// Verifica si un grupo específico está expandido
  bool isGroupExpanded(String groupId) {
    return state.expandedGroupId == groupId;
  }

  /// Cierra todos los grupos
  void closeAllGroups() {
    state = const MenuStateData(expandedGroupId: null);
  }
}
