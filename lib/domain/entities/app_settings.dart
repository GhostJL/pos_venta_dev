import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final bool useInventory;
  final bool useTax;
  final String? printerName;
  final String? printerAddress;
  final int paperWidthMm;

  const AppSettings({
    required this.useInventory,
    required this.useTax,
    this.printerName,
    this.printerAddress,
    this.paperWidthMm = 80,
  });

  factory AppSettings.defaults() {
    return const AppSettings(
      useInventory: true,
      useTax: true,
      paperWidthMm: 80,
    );
  }

  AppSettings copyWith({
    bool? useInventory,
    bool? useTax,
    String? printerName,
    String? printerAddress,
    int? paperWidthMm,
  }) {
    return AppSettings(
      useInventory: useInventory ?? this.useInventory,
      useTax: useTax ?? this.useTax,
      printerName: printerName ?? this.printerName,
      printerAddress: printerAddress ?? this.printerAddress,
      paperWidthMm: paperWidthMm ?? this.paperWidthMm,
    );
  }

  @override
  List<Object?> get props => [
    useInventory,
    useTax,
    printerName,
    printerAddress,
    paperWidthMm,
  ];
}
