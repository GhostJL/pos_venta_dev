import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final bool useInventory;
  final bool useTax;
  final String? printerName;
  final String? printerAddress;
  final int paperWidthMm;

  // Backup and PDF save paths (null = use platform default)
  final String? backupPath;
  final String? pdfSavePath;

  // Print enable/disable flags
  final bool enableSalesPrinting;
  final bool enablePaymentPrinting;
  final bool autoSavePdfWhenPrintDisabled;

  // Automatic backup configuration
  final bool autoBackupEnabled;
  final List<String> autoBackupTimes; // Format: ["09:00", "18:00"]
  final bool backupOnAppClose;
  final bool backupOnLogout;
  final DateTime? lastBackupTime;

  const AppSettings({
    required this.useInventory,
    required this.useTax,
    this.printerName,
    this.printerAddress,
    this.paperWidthMm = 80,
    this.backupPath,
    this.pdfSavePath,
    this.enableSalesPrinting = true,
    this.enablePaymentPrinting = true,
    this.autoSavePdfWhenPrintDisabled = true,
    this.autoBackupEnabled = false,
    this.autoBackupTimes = const [],
    this.backupOnAppClose = true,
    this.backupOnLogout = true,
    this.lastBackupTime,
  });

  factory AppSettings.defaults() {
    return const AppSettings(
      useInventory: true,
      useTax: true,
      paperWidthMm: 80,
      enableSalesPrinting: true,
      enablePaymentPrinting: true,
      autoSavePdfWhenPrintDisabled: true,
      autoBackupEnabled: false,
      autoBackupTimes: [],
      backupOnAppClose: true,
      backupOnLogout: true,
    );
  }

  AppSettings copyWith({
    bool? useInventory,
    bool? useTax,
    String? printerName,
    String? printerAddress,
    int? paperWidthMm,
    String? backupPath,
    String? pdfSavePath,
    bool? enableSalesPrinting,
    bool? enablePaymentPrinting,
    bool? autoSavePdfWhenPrintDisabled,
    bool? autoBackupEnabled,
    List<String>? autoBackupTimes,
    bool? backupOnAppClose,
    bool? backupOnLogout,
    DateTime? lastBackupTime,
  }) {
    return AppSettings(
      useInventory: useInventory ?? this.useInventory,
      useTax: useTax ?? this.useTax,
      printerName: printerName ?? this.printerName,
      printerAddress: printerAddress ?? this.printerAddress,
      paperWidthMm: paperWidthMm ?? this.paperWidthMm,
      backupPath: backupPath ?? this.backupPath,
      pdfSavePath: pdfSavePath ?? this.pdfSavePath,
      enableSalesPrinting: enableSalesPrinting ?? this.enableSalesPrinting,
      enablePaymentPrinting:
          enablePaymentPrinting ?? this.enablePaymentPrinting,
      autoSavePdfWhenPrintDisabled:
          autoSavePdfWhenPrintDisabled ?? this.autoSavePdfWhenPrintDisabled,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      autoBackupTimes: autoBackupTimes ?? this.autoBackupTimes,
      backupOnAppClose: backupOnAppClose ?? this.backupOnAppClose,
      backupOnLogout: backupOnLogout ?? this.backupOnLogout,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
    );
  }

  @override
  List<Object?> get props => [
    useInventory,
    useTax,
    printerName,
    printerAddress,
    paperWidthMm,
    backupPath,
    pdfSavePath,
    enableSalesPrinting,
    enablePaymentPrinting,
    autoSavePdfWhenPrintDisabled,
    autoBackupEnabled,
    autoBackupTimes,
    backupOnAppClose,
    backupOnLogout,
    lastBackupTime,
  ];
}
