import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/domain/repositories/tax_rate_repository.dart';

class CreateTaxRate {
  final TaxRateRepository repository;

  CreateTaxRate(this.repository);

  Future<TaxRate> call(TaxRate taxRate) {
    return repository.createTaxRate(taxRate);
  }
}
