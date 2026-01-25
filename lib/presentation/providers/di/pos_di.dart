import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:posventa/domain/use_cases/pos/calculate_cart_item_use_case.dart';
import 'package:posventa/domain/use_cases/pos/process_sale_use_case.dart';
import 'package:posventa/presentation/providers/di/product_di.dart';
import 'package:posventa/presentation/providers/di/discount_di.dart';
import 'package:posventa/presentation/providers/di/customer_di.dart';
import 'package:posventa/presentation/providers/di/sale_di.dart';

part 'pos_di.g.dart';

@riverpod
CalculateCartItemUseCase calculateCartItemUseCase(Ref ref) =>
    CalculateCartItemUseCase(
      ref.watch(productRepositoryProvider),
      ref.watch(getDiscountsForVariantUseCaseProvider),
    );

@riverpod
Future<ProcessSaleUseCase> processSaleUseCase(Ref ref) async =>
    ProcessSaleUseCase(
      ref.watch(generateNextSaleNumberUseCaseProvider),
      await ref.watch(createSaleUseCaseProvider.future),
      ref.watch(customerRepositoryProvider),
      ref.watch(createCashMovementUseCaseProvider),
    );
