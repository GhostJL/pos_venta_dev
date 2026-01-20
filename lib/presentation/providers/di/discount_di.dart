import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/data/datasources/discount_local_datasource.dart';
import 'package:posventa/data/datasources/local/discount_local_datasource_impl.dart';
import 'package:posventa/data/repositories/discount_repository_impl.dart';
import 'package:posventa/domain/repositories/discount_repository.dart';
import 'package:posventa/domain/use_cases/discount/get_all_discounts_use_case.dart';
import 'package:posventa/domain/use_cases/discount/create_discount_use_case.dart';
import 'package:posventa/domain/use_cases/discount/update_discount_use_case.dart';
import 'package:posventa/domain/use_cases/discount/delete_discount_use_case.dart';
import 'package:posventa/domain/use_cases/discount/get_discounts_for_variant_use_case.dart';
import 'package:posventa/domain/use_cases/discount/update_variant_discounts_use_case.dart';
import 'package:posventa/presentation/providers/di/core_di.dart';

part 'discount_di.g.dart';

@riverpod
DiscountLocalDataSource discountLocalDataSource(ref) =>
    DiscountLocalDataSourceImpl(ref.watch(appDatabaseProvider));

@riverpod
DiscountRepository discountRepository(ref) =>
    DiscountRepositoryImpl(ref.watch(discountLocalDataSourceProvider));

@riverpod
GetAllDiscountsUseCase getAllDiscountsUseCase(ref) =>
    GetAllDiscountsUseCase(ref.watch(discountRepositoryProvider));

@riverpod
CreateDiscountUseCase createDiscountUseCase(ref) =>
    CreateDiscountUseCase(ref.watch(discountRepositoryProvider));

@riverpod
UpdateDiscountUseCase updateDiscountUseCase(ref) =>
    UpdateDiscountUseCase(ref.watch(discountRepositoryProvider));

@riverpod
DeleteDiscountUseCase deleteDiscountUseCase(ref) =>
    DeleteDiscountUseCase(ref.watch(discountRepositoryProvider));

@riverpod
GetDiscountsForVariantUseCase getDiscountsForVariantUseCase(ref) =>
    GetDiscountsForVariantUseCase(ref.watch(discountRepositoryProvider));

@riverpod
UpdateVariantDiscountsUseCase updateVariantDiscountsUseCase(ref) =>
    UpdateVariantDiscountsUseCase(ref.watch(discountRepositoryProvider));
