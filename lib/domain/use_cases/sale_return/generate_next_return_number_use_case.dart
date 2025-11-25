import 'package:posventa/domain/repositories/sale_return_repository.dart';

class GenerateNextReturnNumberUseCase {
  final SaleReturnRepository _repository;

  GenerateNextReturnNumberUseCase(this._repository);

  Future<String> call() async {
    return await _repository.generateNextReturnNumber();
  }
}
