import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';

class ProductFormControllers {
  final TextEditingController nameController;
  final TextEditingController codeController;
  final TextEditingController barcodeController;
  final TextEditingController descriptionController;
  final TextEditingController costController;
  final TextEditingController priceController;
  final TextEditingController wholesaleController;
  final TextEditingController minStockController;
  final TextEditingController maxStockController;

  ProductFormControllers({
    required this.nameController,
    required this.codeController,
    required this.barcodeController,
    required this.descriptionController,
    required this.costController,
    required this.priceController,
    required this.wholesaleController,
    required this.minStockController,
    required this.maxStockController,
  });

  factory ProductFormControllers.fromProduct(Product? product) {
    // Initialize with empty or existing values
    ProductVariant? defaultVariant;
    if (product?.variants != null && product!.variants!.isNotEmpty) {
      defaultVariant = product.variants!.first;
    }

    return ProductFormControllers(
      nameController: TextEditingController(text: product?.name),
      codeController: TextEditingController(text: product?.code),
      barcodeController: TextEditingController(text: product?.barcode),
      descriptionController: TextEditingController(text: product?.description),
      costController: TextEditingController(
        text: defaultVariant != null
            ? (defaultVariant.costPriceCents / 100).toStringAsFixed(2)
            : '',
      ),
      priceController: TextEditingController(
        text: defaultVariant != null
            ? (defaultVariant.priceCents / 100).toStringAsFixed(2)
            : '',
      ),
      wholesaleController: TextEditingController(
        text: defaultVariant?.wholesalePriceCents != null
            ? (defaultVariant!.wholesalePriceCents! / 100).toStringAsFixed(2)
            : '',
      ),
      minStockController: TextEditingController(
        text: defaultVariant != null
            ? _formatDouble(defaultVariant.stockMin)
            : '',
      ),
      maxStockController: TextEditingController(
        text: defaultVariant != null
            ? _formatDouble(defaultVariant.stockMax)
            : '',
      ),
    );
  }

  void dispose() {
    nameController.dispose();
    codeController.dispose();
    barcodeController.dispose();
    descriptionController.dispose();
    costController.dispose();
    priceController.dispose();
    wholesaleController.dispose();
    minStockController.dispose();
    maxStockController.dispose();
  }

  static String _formatDouble(double? value) {
    if (value == null) return '';
    return value.toString().replaceAll(RegExp(r'\.0$'), ''); // Remove .0
  }
}
