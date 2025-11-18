import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/domain/repositories/tax_rate_repository.dart';

class GetAllTaxRates {
  final TaxRateRepository repository;

  GetAllTaxRates(this.repository);

  Future<List<TaxRate>> call() {
    return repository.getAllTaxRates();
  }
}
