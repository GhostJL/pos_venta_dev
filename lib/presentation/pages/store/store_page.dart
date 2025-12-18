import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/store_provider.dart';
import 'package:posventa/domain/entities/store.dart';
import 'package:posventa/presentation/pages/store/sections/store_info_section.dart';

class StorePage extends ConsumerStatefulWidget {
  const StorePage({super.key});

  @override
  ConsumerState<StorePage> createState() => _StorePageState();
}

class _StorePageState extends ConsumerState<StorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final storeAsync = ref.watch(storeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Tienda'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Información General', icon: Icon(Icons.info_outline)),
            Tab(
              text: 'Configuración de Ticket',
              icon: Icon(Icons.receipt_long_outlined),
            ),
          ],
        ),
      ),
      body: storeAsync.when(
        data: (store) {
          if (store == null) {
            return const Center(
              child: Text('No se encontró información de la tienda.'),
            );
          }
          return TabBarView(
            controller: _tabController,
            children: [
              StoreInfoSection(store: store),
              _ReceiptConfigSection(store: store),
            ],
          );
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
          Text(
            'Pie de página del ticket',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _footerController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Ej: Gracias por su compra, vuelva pronto!',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final updatedStore = widget.store.copyWith(
                receiptFooter: _footerController.text,
              );
              ref.read(storeProvider.notifier).updateStore(updatedStore);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración guardada')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
