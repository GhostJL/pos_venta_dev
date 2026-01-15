import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/store_provider.dart';
import 'package:posventa/presentation/pages/store/sections/store_info_section.dart';

class StorePage extends ConsumerWidget {
  const StorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(storeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Tienda')),
      body: storeAsync.when(
        data: (store) {
          if (store == null) {
            return const Center(
              child: Text('No se encontró información de la tienda.'),
            );
          }
          return StoreInfoSection(store: store);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
