import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/store.dart';
import 'package:posventa/presentation/providers/store_provider.dart';

class TicketConfigPage extends ConsumerStatefulWidget {
  const TicketConfigPage({super.key});

  @override
  ConsumerState<TicketConfigPage> createState() => _TicketConfigPageState();
}

class _TicketConfigPageState extends ConsumerState<TicketConfigPage> {
  @override
  Widget build(BuildContext context) {
    final storeAsync = ref.watch(storeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración de Ticket')),
      body: storeAsync.when(
        data: (store) {
          if (store == null) {
            return const Center(
              child: Text('No se encontró información de la tienda.'),
            );
          }
          return _ReceiptConfigSection(store: store);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _ReceiptConfigSection extends ConsumerStatefulWidget {
  final Store store;
  const _ReceiptConfigSection({required this.store});

  @override
  ConsumerState<_ReceiptConfigSection> createState() =>
      _ReceiptConfigSectionState();
}

class _ReceiptConfigSectionState extends ConsumerState<_ReceiptConfigSection> {
  final _footerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _footerController.text = widget.store.receiptFooter ?? '';
  }

  @override
  void dispose() {
    _footerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pie de página del ticket',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Este mensaje aparecerá al final de todos los tickets impresos.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _footerController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Ej: Gracias por su compra, vuelva pronto!',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: () {
                        final updatedStore = widget.store.copyWith(
                          receiptFooter: _footerController.text,
                        );
                        ref
                            .read(storeProvider.notifier)
                            .updateStore(updatedStore);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Configuración guardada'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
