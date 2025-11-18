import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/pages/product_form_page.dart';
import 'package:posventa/presentation/providers/product_provider.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: products.when(
        data: (productList) => ListView.builder(
          itemCount: productList.length,
          itemBuilder: (context, index) {
            final product = productList[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text(product.code),
              trailing: Text(
                '\$${(product.salePriceCents / 100).toStringAsFixed(2)}',
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductFormPage(product: product),
                  ),
                );
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ProductFormPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
