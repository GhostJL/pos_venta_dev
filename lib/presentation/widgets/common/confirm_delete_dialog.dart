import 'package:flutter/material.dart';

/// Widget reutilizable para diálogos de confirmación de eliminación.
///
/// Este widget proporciona un diálogo consistente para confirmar
/// la eliminación de elementos en toda la aplicación.
class ConfirmDeleteDialog extends StatelessWidget {
  /// Nombre del elemento a eliminar (ej: "Producto X")
  final String itemName;

  /// Tipo de elemento (ej: "producto", "categoría", "marca")
  final String itemType;

  /// Callback que se ejecuta cuando el usuario confirma la eliminación
  final VoidCallback onConfirm;

  /// Mensaje de éxito opcional que se muestra en el SnackBar
  /// Si no se proporciona, se usa un mensaje por defecto
  final String? successMessage;

  const ConfirmDeleteDialog({
    super.key,
    required this.itemName,
    required this.itemType,
    required this.onConfirm,
    this.successMessage,
  });

  /// Muestra el diálogo de confirmación y retorna true si se confirmó
  static Future<bool?> show({
    required BuildContext context,
    required String itemName,
    required String itemType,
    required VoidCallback onConfirm,
    String? successMessage,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return ConfirmDeleteDialog(
          itemName: itemName,
          itemType: itemType,
          onConfirm: onConfirm,
          successMessage: successMessage,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Confirmar Eliminación'),
      content: Text(
        '¿Estás seguro de que quieres eliminar $itemType "$itemName"?',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actionsPadding: const EdgeInsets.all(20),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Eliminar'),
          onPressed: () {
            // Ejecutar el callback de eliminación
            onConfirm();

            // Cerrar el diálogo
            Navigator.of(context).pop(true);

            // Mostrar SnackBar de éxito
            final message =
                successMessage ??
                '${itemType[0].toUpperCase()}${itemType.substring(1)} eliminado correctamente';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Theme.of(context).colorScheme.tertiary,
              ),
            );
          },
        ),
      ],
    );
  }
}
