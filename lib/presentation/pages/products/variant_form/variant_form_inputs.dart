import 'package:flutter/material.dart';

class VariantFormInputs {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController priceController;
  final TextEditingController costController;
  final TextEditingController wholesaleController;
  final TextEditingController barcodeController;
  final TextEditingController conversionController;
  final TextEditingController stockMinController;
  final TextEditingController stockMaxController;
  final TextEditingController marginController;

  final FocusNode priceFocus;
  final FocusNode costFocus;
  final FocusNode marginFocus;

  VariantFormInputs({
    required this.nameController,
    required this.quantityController,
    required this.priceController,
    required this.costController,
    required this.wholesaleController,
    required this.barcodeController,
    required this.conversionController,
    required this.stockMinController,
    required this.stockMaxController,
    required this.marginController,
    required this.priceFocus,
    required this.costFocus,
    required this.marginFocus,
  });

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    costController.dispose();
    wholesaleController.dispose();
    barcodeController.dispose();
    conversionController.dispose();
    stockMinController.dispose();
    stockMaxController.dispose();
    marginController.dispose();
    priceFocus.dispose();
    costFocus.dispose();
    marginFocus.dispose();
  }
}
