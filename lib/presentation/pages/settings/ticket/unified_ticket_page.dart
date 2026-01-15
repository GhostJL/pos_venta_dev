import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/store.dart';
import 'package:posventa/presentation/providers/store_provider.dart';
import 'package:posventa/presentation/pages/settings/ticket/widgets/ticket_preview_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class UnifiedTicketPage extends ConsumerStatefulWidget {
  const UnifiedTicketPage({super.key});

  @override
  ConsumerState<UnifiedTicketPage> createState() => _UnifiedTicketPageState();
}

class _UnifiedTicketPageState extends ConsumerState<UnifiedTicketPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _businessNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _taxIdController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _footerController;

  // Local state for preview
  Store? _previewStore;
  String? _logoPath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _businessNameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _taxIdController = TextEditingController();
    _emailController = TextEditingController();
    _websiteController = TextEditingController();
    _footerController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _taxIdController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  void _initializeControllers(Store store) {
    if (_previewStore == null) {
      // Only init once
      _previewStore = store;
      _nameController.text = store.name;
      _businessNameController.text = store.businessName ?? '';
      _addressController.text = store.address ?? '';
      _phoneController.text = store.phone ?? '';
      _taxIdController.text = store.taxId ?? '';
      _emailController.text = store.email ?? '';
      _websiteController.text = store.website ?? '';
      _footerController.text = store.receiptFooter ?? '';
    }
  }

  Future<void> _pickLogo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _logoPath = result.files.single.path;
        _previewStore = _previewStore?.copyWith(logoPath: _logoPath);
      });
    }
  }

  void _removeLogo() {
    setState(() {
      _logoPath = null;
      _previewStore = _previewStore?.copyWith(logoPath: '');
    });
  }

  void _updatePreview() {
    if (_previewStore == null) return;
    setState(() {
      _previewStore = _previewStore!.copyWith(
        name: _nameController.text,
        businessName: _businessNameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        taxId: _taxIdController.text,
        email: _emailController.text,
        website: _websiteController.text,
        receiptFooter: _footerController.text,
      );
    });
  }

  Future<void> _saveChanges() async {
    if (_previewStore == null) return;
    if (_formKey.currentState?.validate() != true) return;

    try {
      if (_previewStore == null) return;
      await ref.read(storeProvider.notifier).updateStore(_previewStore!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuración guardada correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeAsync = ref.watch(storeProvider);
    final isLargeScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos del Negocio y Ticket'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
            tooltip: 'Guardar cambios',
          ),
        ],
      ),
      body: storeAsync.when(
        data: (store) {
          if (store == null) {
            return const Center(child: Text('Error: No store data'));
          }

          _initializeControllers(store);

          Widget formSection = SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, 'Información del Negocio'),
                  const SizedBox(height: 16),

                  // LOGO PICKER
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child:
                              _previewStore?.logoPath != null &&
                                  _previewStore!.logoPath!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(_previewStore!.logoPath!),
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.broken_image,
                                        size: 40,
                                        color: Colors.grey,
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
                                  Icons.add_photo_alternate,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              onPressed: _pickLogo,
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Cargar Logo'),
                            ),
                            if (_previewStore?.logoPath != null &&
                                _previewStore!.logoPath!.isNotEmpty)
                              TextButton.icon(
                                onPressed: _removeLogo,
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  'Eliminar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la Tienda',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.store),
                    ),
                    onChanged: (_) => _updatePreview(),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _businessNameController,
                    decoration: const InputDecoration(
                      labelText: 'Razón Social',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                    onChanged: (_) => _updatePreview(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                    onChanged: (_) => _updatePreview(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          onChanged: (_) => _updatePreview(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _taxIdController,
                          decoration: const InputDecoration(
                            labelText: 'RFC / Tax ID',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.badge),
                          ),
                          onChanged: (_) => _updatePreview(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    onChanged: (_) => _updatePreview(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _websiteController,
                    decoration: const InputDecoration(
                      labelText: 'Sitio Web',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.language),
                    ),
                    onChanged: (_) => _updatePreview(),
                  ),

                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'Personalización del Ticket'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _footerController,
                    decoration: const InputDecoration(
                      labelText: 'Mensaje de Pie de Página',
                      helperText:
                          'Este mensaje aparecerá al final de todos los tickets',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.short_text),
                    ),
                    maxLines: 3,
                    onChanged: (_) => _updatePreview(),
                  ),
                ],
              ),
            ),
          );

          Widget previewSection = Container(
            color: Colors.grey[100],
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'VISTA PREVIA DE IMPRESIÓN',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TicketPreviewWidget(store: _previewStore ?? store),
                  ],
                ),
              ),
            ),
          );

          if (isLargeScreen) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: formSection), // 60%
                Container(width: 1, color: Colors.grey[300]),
                Expanded(flex: 2, child: previewSection), // 40%
              ],
            );
          } else {
            // On mobile, use tabs or just vertical scroll.
            // Vertical scroll might be too long. Tabs "Editar" vs "Vista Previa" is nice.
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'EDITAR'),
                      Tab(text: 'VISTA PREVIA'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(children: [formSection, previewSection]),
                  ),
                ],
              ),
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const Divider(),
      ],
    );
  }
}
