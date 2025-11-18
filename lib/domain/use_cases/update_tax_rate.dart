import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/domain/repositories/tax_rate_repository.dart';

class UpdateTaxRate {
  final TaxRateRepository repository;

  UpdateTaxRate(this.repository);

  Future<TaxRate> call(TaxRate taxRate) {
    return repository.updateTaxRate(taxRate);
  }
}
