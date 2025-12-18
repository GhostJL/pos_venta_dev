import 'package:posventa/domain/entities/brand.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/repositories/brand_repository.dart';
import 'package:posventa/data/repositories/brand_repository_impl.dart';
import 'package:posventa/domain/use_cases/brand/create_brand.dart';
import 'package:posventa/domain/use_cases/brand/delete_brand.dart';
import 'package:posventa/domain/use_cases/brand/get_all_brands.dart';
import 'package:posventa/domain/use_cases/brand/update_brand.dart';

part 'brand_providers.g.dart';

@riverpod
BrandRepository brandRepository(ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return BrandRepositoryImpl(dbHelper);
}

@Riverpod(keepAlive: true)
GetAllBrands getAllBrandsUseCase(ref) {
  return GetAllBrands(ref.watch(brandRepositoryProvider));
}

@riverpod
CreateBrand createBrandUseCase(ref) {
  return CreateBrand(ref.watch(brandRepositoryProvider));
}

@riverpod
UpdateBrand updateBrandUseCase(ref) {
  return UpdateBrand(ref.watch(brandRepositoryProvider));
}

@riverpod
DeleteBrand deleteBrandUseCase(ref) {
  return DeleteBrand(ref.watch(brandRepositoryProvider));
}

@Riverpod(keepAlive: true)
class BrandList extends _$BrandList {
  @override
  Future<List<Brand>> build() async {
    final getAllBrands = ref.watch(getAllBrandsUseCaseProvider);
    return getAllBrands();
  }

  Future<Brand?> addBrand(Brand brand) async {
    state = const AsyncValue.loading();
    Brand? newBrand;
    state = await AsyncValue.guard(() async {
      newBrand = await ref.read(createBrandUseCaseProvider).call(brand);
      return ref.read(getAllBrandsUseCaseProvider).call();
    });
    return newBrand;
  }

  Future<void> updateBrand(Brand brand) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateBrandUseCaseProvider).call(brand);
      return ref.read(getAllBrandsUseCaseProvider).call();
    });
  }

  Future<void> deleteBrand(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteBrandUseCaseProvider).call(id);
      return ref.read(getAllBrandsUseCaseProvider).call();
    });
  }
}
