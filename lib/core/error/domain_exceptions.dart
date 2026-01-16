/// Exception thrown when a sale cannot be found
class SaleNotFoundException implements Exception {
  final String message;
  final int saleId;
  SaleNotFoundException(this.saleId, {this.message = 'Sale not found'});
}

/// Exception thrown when trying to perform an action on a cancelled sale
class SaleAlreadyCancelledException implements Exception {
  final String message;
  final int saleId;
  SaleAlreadyCancelledException(
    this.saleId, {
    this.message = 'La venta ya está cancelada',
  });
}

/// Exception thrown when trying to cancel a returned sale
class SaleAlreadyReturnedException implements Exception {
  final String message;
  final int saleId;
  SaleAlreadyReturnedException(
    this.saleId, {
    this.message = 'La venta ya ha sido devuelta',
  });
}

/// Exception thrown when there is an issue with cash movements
class CashMovementException implements Exception {
  final String message;
  final String? reason;
  CashMovementException(this.message, {this.reason});
}

/// Exception thrown when there is insufficient stock
class StockInsufficientException implements Exception {
  final String productName;
  final double currentStock;
  final double requestedQuantity;

  StockInsufficientException({
    required this.productName,
    required this.currentStock,
    required this.requestedQuantity,
  });

  @override
  String toString() =>
      'StockInsufficientException: Stock insuficiente para $productName. Disponible: $currentStock, Solicitado: $requestedQuantity';
}

/// Exception thrown during backup operations
class BackupException implements Exception {
  final String message;
  final dynamic originalError;
  BackupException(this.message, {this.originalError});
}

/// Exception thrown during notification operations
class NotificationException implements Exception {
  final String message;
  final dynamic originalError;
  NotificationException(this.message, {this.originalError});
}

// Re-export core exceptions for convenience if needed,
// strictly we should use these specific ones.
