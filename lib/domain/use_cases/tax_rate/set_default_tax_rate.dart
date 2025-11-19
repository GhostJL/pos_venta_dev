import 'package:posventa/domain/repositories/tax_rate_repository.dart';

class SetDefaultTaxRate {
  final TaxRateRepository repository;

  SetDefaultTaxRate(this.repository);

  Future<void> call(int id) {
    return repository.setDefaultTaxRate(id);
  }
}
