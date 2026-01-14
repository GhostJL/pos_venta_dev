class StorageKeys {
  static const String useInventory = 'settings_use_inventory';
  static const String useTax = 'settings_use_tax';
  static const String printerName = 'settings_printer_name';
  static const String printerAddress = 'settings_printer_address';
  static const String paperWidthMm = 'settings_paper_width_mm';
  static const String paymentReceiptAction = 'settings_payment_receipt_action';

  // Backup and PDF paths
  static const String backupPath = 'settings_backup_path';
  static const String pdfSavePath = 'settings_pdf_save_path';

  // Print enable/disable flags
  static const String enableSalesPrinting = 'settings_enable_sales_printing';
  static const String enablePaymentPrinting =
      'settings_enable_payment_printing';
  static const String autoSavePdfWhenPrintDisabled =
      'settings_auto_save_pdf_when_print_disabled';

  // Automatic backup settings
  static const String autoBackupEnabled = 'auto_backup_enabled';
  static const String autoBackupTimes = 'auto_backup_times';
  static const String backupOnAppClose = 'backup_on_app_close';
  static const String backupOnLogout = 'backup_on_logout';
  static const String lastBackupTime = 'last_backup_time';
}
