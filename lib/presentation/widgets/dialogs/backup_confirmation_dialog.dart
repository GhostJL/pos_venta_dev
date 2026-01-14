import 'package:flutter/material.dart';

/// Dialog to confirm backup before closing app or logging out
class BackupConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;
  final Future<bool> Function() onBackup;

  const BackupConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onBackup,
  });

  @override
  State<BackupConfirmationDialog> createState() =>
      _BackupConfirmationDialogState();
}

class _BackupConfirmationDialogState extends State<BackupConfirmationDialog> {
  bool _isBackingUp = false;
  String? _errorMessage;

  Future<void> _executeBackup() async {
    setState(() {
      _isBackingUp = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.onBackup();
      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true); // Return true = backup done
        } else {
          setState(() {
            _errorMessage = 'Error al crear el backup';
            _isBackingUp = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isBackingUp = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message),
          if (_isBackingUp) ...[
            const SizedBox(height: 16),
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Creando backup...'),
                ],
              ),
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!_isBackingUp) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuar sin backup'),
          ),
          FilledButton.icon(
            onPressed: _executeBackup,
            icon: const Icon(Icons.backup),
            label: const Text('Crear backup'),
          ),
        ],
      ],
    );
  }
}

/// Show backup confirmation dialog
Future<bool?> showBackupConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  required Future<bool> Function() onBackup,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => BackupConfirmationDialog(
      title: title,
      message: message,
      onBackup: onBackup,
    ),
  );
}
