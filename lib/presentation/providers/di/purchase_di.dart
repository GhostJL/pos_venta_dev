import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/repositories/purchase_repository.dart';
import 'package:posventa/data/repositories/purchase_repository_impl.dart';
import 'package:posventa/domain/use_cases/purchase/get_purchases_usecase.dart';
import 'package:posventa/domain/use_cases/purchase/get_purchase_by_id_usecase.dart';
import 'package:posventa/domain/use_cases/purchase/create_purchase_usecase.dart';
import 'package:posventa/domain/use_cases/purchase/update_purchase_usecase.dart';
import 'package:posventa/domain/use_cases/purchase/delete_purchase_usecase.dart';
import 'package:posventa/domain/use_cases/purchase/receive_purchase_usecase.dart';
import 'package:posventa/domain/use_cases/purchase/cancel_purchase_usecase.dart';
import 'package:posventa/domain/repositories/purchase_item_repository.dart';
import 'package:posventa/data/repositories/purchase_item_repository_impl.dart';
import 'package:posventa/domain/use_cases/purchase_item/get_purchase_items_usecase.dart';
import 'package:posventa/domain/use_cases/purchase_item/get_purchase_items_by_purchase_id_usecase.dart';
import 'package:posventa/domain/use_cases/purchase_item/get_purchase_item_by_id_usecase.dart';
import 'package:posventa/domain/use_cases/purchase_item/get_purchase_items_by_product_id_usecase.dart';
import 'package:posventa/domain/use_cases/purchase_item/create_purchase_item_usecase.dart';
import 'package:posventa/domain/use_cases/purchase_item/update_purchase_item_usecase.dart';
import 'package:posventa/domain/use_cases/purchase_item/delete_purchase_item_usecase.dart';
import 'package:posventa/domain/use_cases/purchase_item/get_purchase_items_by_date_range_usecase.dart';
import 'package:posventa/domain/use_cases/purchase_item/get_recent_purchase_items_usecase.dart';
import 'package:posventa/domain/services/variant_conversion_service.dart';
import 'package:posventa/presentation/providers/di/core_di.dart';
import 'package:posventa/presentation/providers/di/product_di.dart';

part 'purchase_di.g.dart';

// --- Purchase Providers ---

@riverpod
PurchaseRepository purchaseRepository(ref) =>
    PurchaseRepositoryImpl(ref.watch(appDatabaseProvider));

@riverpod
GetPurchasesUseCase getPurchasesUseCase(ref) =>
    GetPurchasesUseCase(ref.watch(purchaseRepositoryProvider));

@riverpod
GetPurchaseByIdUseCase getPurchaseByIdUseCase(ref) =>
    GetPurchaseByIdUseCase(ref.watch(purchaseRepositoryProvider));

@riverpod
CreatePurchaseUseCase createPurchaseUseCase(ref) =>
    CreatePurchaseUseCase(ref.watch(purchaseRepositoryProvider));

@riverpod
UpdatePurchaseUseCase updatePurchaseUseCase(ref) =>
    UpdatePurchaseUseCase(ref.watch(purchaseRepositoryProvider));

@riverpod
DeletePurchaseUseCase deletePurchaseUseCase(ref) =>
    DeletePurchaseUseCase(ref.watch(purchaseRepositoryProvider));

@riverpod
VariantConversionService variantConversionService(ref) =>
    VariantConversionService();

@riverpod
ReceivePurchaseUseCase receivePurchaseUseCase(ref) => ReceivePurchaseUseCase(
  ref.watch(purchaseRepositoryProvider),
  ref.watch(productRepositoryProvider),
  ref.watch(variantConversionServiceProvider),
);

@riverpod
CancelPurchaseUseCase cancelPurchaseUseCase(ref) =>
    CancelPurchaseUseCase(ref.watch(purchaseRepositoryProvider));

// --- Purchase Item Providers ---

@riverpod
PurchaseItemRepository purchaseItemRepository(ref) =>
    PurchaseItemRepositoryImpl(ref.watch(appDatabaseProvider));

@riverpod
GetPurchaseItemsUseCase getPurchaseItemsUseCase(ref) =>
    GetPurchaseItemsUseCase(ref.watch(purchaseItemRepositoryProvider));

@riverpod
GetPurchaseItemsByPurchaseIdUseCase getPurchaseItemsByPurchaseIdUseCase(ref) =>
    GetPurchaseItemsByPurchaseIdUseCase(
      ref.watch(purchaseItemRepositoryProvider),
    );

@riverpod
GetPurchaseItemByIdUseCase getPurchaseItemByIdUseCase(ref) =>
    GetPurchaseItemByIdUseCase(ref.watch(purchaseItemRepositoryProvider));

@riverpod
GetPurchaseItemsByProductIdUseCase getPurchaseItemsByProductIdUseCase(ref) =>
    GetPurchaseItemsByProductIdUseCase(
      ref.watch(purchaseItemRepositoryProvider),
    );

@riverpod
CreatePurchaseItemUseCase createPurchaseItemUseCase(ref) =>
    CreatePurchaseItemUseCase(ref.watch(purchaseItemRepositoryProvider));

@riverpod
UpdatePurchaseItemUseCase updatePurchaseItemUseCase(ref) =>
    UpdatePurchaseItemUseCase(ref.watch(purchaseItemRepositoryProvider));

@riverpod
DeletePurchaseItemUseCase deletePurchaseItemUseCase(ref) =>
    DeletePurchaseItemUseCase(ref.watch(purchaseItemRepositoryProvider));

@riverpod
GetPurchaseItemsByDateRangeUseCase getPurchaseItemsByDateRangeUseCase(ref) =>
    GetPurchaseItemsByDateRangeUseCase(
      ref.watch(purchaseItemRepositoryProvider),
    );

@riverpod
GetRecentPurchaseItemsUseCase getRecentPurchaseItemsUseCase(ref) =>
    GetRecentPurchaseItemsUseCase(ref.watch(purchaseItemRepositoryProvider));
