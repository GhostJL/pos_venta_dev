import 'package:posventa/domain/repositories/tax_rate_repository.dart';

class DeleteTaxRate {
  final TaxRateRepository repository;

  DeleteTaxRate(this.repository);

  Future<void> call(int id) {
    return repository.deleteTaxRate(id);
  }
}
