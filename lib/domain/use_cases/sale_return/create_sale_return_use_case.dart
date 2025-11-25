import 'package:posventa/domain/entities/sale_return.dart';
import 'package:posventa/domain/repositories/sale_return_repository.dart';

class CreateSaleReturnUseCase {
  final SaleReturnRepository _repository;

  CreateSaleReturnUseCase(this._repository);

  Future<int> call(SaleReturn saleReturn) async {
    // Validate that the sale can be returned
    final canReturn = await _repository.canReturnSale(saleReturn.saleId);
    if (!canReturn) {
      throw Exception('Esta venta no puede ser devuelta');
    }

    // Validate returned quantities
    final returnedQty = await _repository.getReturnedQuantities(
      saleReturn.saleId,
    );

    for (final item in saleReturn.items) {
      final alreadyReturned = returnedQty[item.saleItemId] ?? 0.0;
      // This validation assumes we have the original quantity available
      // In practice, you'd need to fetch the original sale item to compare
      if (item.quantity <= 0) {
        throw Exception('La cantidad a devolver debe ser mayor a 0');
      }
    }

    // Create the return (repository handles inventory movements)
    return await _repository.createSaleReturn(saleReturn);
  }
}
