import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// For debugPrint

class ImagePickerWidget extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final Function(File) onImageSelected;
  final VoidCallback onRemoveImage;
  final double size;

  const ImagePickerWidget({
    super.key,
    this.imageFile,
    this.imageUrl,
    required this.onImageSelected,
    required this.onRemoveImage,
    this.size = 120,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        onImageSelected(File(pickedFile.path));
      }
    } catch (e) {
      // Handle error gracefully, maybe show snackbar if context available
      debugPrint('Error picking image: $e');
    }
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(context, ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    ImageProvider? imageProvider;
    if (imageFile != null) {
      imageProvider = FileImage(imageFile!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (imageUrl!.startsWith('http')) {
        imageProvider = NetworkImage(imageUrl!);
      } else {
        imageProvider = FileImage(File(imageUrl!));
      }
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () => _showPickerOptions(context),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant, width: 1),
              image: imageProvider != null
                  ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                  : null,
            ),
            child: imageProvider == null
                ? Icon(
                    Icons.add_a_photo_outlined,
                    size: size * 0.4,
                    color: colorScheme.onSurfaceVariant,
                  )
                : null,
          ),
        ),
        if (imageProvider != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRemoveImage,
            icon: Icon(
              Icons.delete_outline,
              size: 18,
              color: colorScheme.error,
            ),
            label: Text(
              'Eliminar foto',
              style: TextStyle(color: colorScheme.error),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _showPickerOptions(context),
            icon: Icon(Icons.image_outlined, size: 18),
            label: const Text('Agregar foto'),
          ),
        ],
      ],
    );
  }
}
