/// Reusable validators for purchase forms
class PurchaseValidators {
  /// Validates quantity input
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Requerido';
    }

    final quantity = double.tryParse(value);
    if (quantity == null) {
      return 'Inválido';
    }

    if (quantity <= 0) {
      return 'Debe ser mayor a 0';
    }

    return null;
  }

  /// Validates cost input
  static String? validateCost(String? value) {
    if (value == null || value.isEmpty) {
      return 'Requerido';
    }

    final cost = double.tryParse(value);
    if (cost == null) {
      return 'Inválido';
    }

    if (cost < 0) {
      return 'No puede ser negativo';
    }

    return null;
  }

  /// Generic validator for positive numbers
  static String? validatePositiveNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Requerido';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Número inválido';
    }

    if (number <= 0) {
      return 'Debe ser mayor a 0';
    }

    return null;
  }

  /// Validates non-negative numbers (allows 0)
  static String? validateNonNegativeNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Requerido';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Número inválido';
    }

    if (number < 0) {
      return 'No puede ser negativo';
    }

    return null;
  }
}
