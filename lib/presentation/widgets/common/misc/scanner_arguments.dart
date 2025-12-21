import 'package:flutter/material.dart';

class ScannerArguments {
  final Future<(bool, String)> Function(BuildContext context, String barcode)?
  onScan;
  final String? titleOverride;
  final bool showManualInput;

  const ScannerArguments({
    this.onScan,
    this.titleOverride,
    this.showManualInput = false,
  });
}
