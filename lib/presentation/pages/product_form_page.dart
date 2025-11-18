import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/presentation/providers/product_provider.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  ProductFormPageState createState() => ProductFormPageState();
}

class ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _code;
  late int _salePriceCents;

  @override
  void initState() {
    super.initState();
    _name = widget.product?.name ?? '';
    _code = widget.product?.code ?? '';
    _salePriceCents = widget.product?.salePriceCents ?? 0;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final product = Product(
        id: widget.product?.id,
        name: _name,
        code: _code,
        salePriceCents: _salePriceCents,
        // Add default values for other required fields
        departmentId: 1,
        categoryId: 1,
        unitOfMeasure: 'unit',
        isSoldByWeight: false,
        costPriceCents: 0,
        isActive: true,
      );
      if (widget.product == null) {
        ref.read(productNotifierProvider.notifier).createProduct(product);
      } else {
        ref.read(productNotifierProvider.notifier).updateProduct(product);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _code,
                decoration: const InputDecoration(labelText: 'Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a code';
                  }
                  return null;
                },
                onSaved: (value) => _code = value!,
              ),
              TextFormField(
                initialValue: (_salePriceCents / 100).toStringAsFixed(2),
                decoration: const InputDecoration(labelText: 'Sale Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a sale price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) =>
                    _salePriceCents = (double.parse(value!) * 100).toInt(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.product == null ? 'Create' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
