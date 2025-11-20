import 'package:posventa/domain/repositories/sale_repository.dart';

class GenerateNextSaleNumberUseCase {
  final SaleRepository _repository;

  GenerateNextSaleNumberUseCase(this._repository);

  Future<String> call() async {
    return await _repository.generateNextSaleNumber();
  }
}
