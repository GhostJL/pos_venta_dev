import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:posventa/data/repositories/brand_repository_impl.dart';
import 'package:posventa/domain/entities/brand.dart';
import 'package:posventa/domain/repositories/brand_repository.dart';
import 'package:posventa/domain/use_cases/create_brand.dart';
import 'package:posventa/domain/use_cases/delete_brand.dart';
import 'package:posventa/domain/use_cases/get_all_brands.dart';
import 'package:posventa/domain/use_cases/update_brand.dart';
import 'package:posventa/presentation/providers/department_providers.dart';

final brandRepositoryProvider = Provider<BrandRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return BrandRepositoryImpl(dbHelper);
});

final getAllBrandsProvider = Provider<GetAllBrands>((ref) {
  final repository = ref.watch(brandRepositoryProvider);
  return GetAllBrands(repository);
});

final createBrandProvider = Provider<CreateBrand>((ref) {
  final repository = ref.watch(brandRepositoryProvider);
  return CreateBrand(repository);
});

final updateBrandProvider = Provider<UpdateBrand>((ref) {
  final repository = ref.watch(brandRepositoryProvider);
  return UpdateBrand(repository);
});

final deleteBrandProvider = Provider<DeleteBrand>((ref) {
  final repository = ref.watch(brandRepositoryProvider);
  return DeleteBrand(repository);
});

final brandListProvider =
    StateNotifierProvider<BrandListNotifier, AsyncValue<List<Brand>>>((ref) {
      return BrandListNotifier(ref);
    });

class BrandListNotifier extends StateNotifier<AsyncValue<List<Brand>>> {
  final Ref _ref;

  BrandListNotifier(this._ref) : super(const AsyncValue.loading()) {
    fetchBrands();
  }

  Future<void> fetchBrands() async {
    state = const AsyncValue.loading();
    try {
      final getAllBrands = _ref.read(getAllBrandsProvider);
      final brands = await getAllBrands();
      state = AsyncValue.data(brands);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createBrand(Brand brand) async {
    try {
      final createBrand = _ref.read(createBrandProvider);
      await createBrand(brand);
      fetchBrands();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateBrand(Brand brand) async {
    try {
      final updateBrand = _ref.read(updateBrandProvider);
      await updateBrand(brand);
      fetchBrands();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteBrand(int brandId) async {
    try {
      final deleteBrand = _ref.read(deleteBrandProvider);
      await deleteBrand(brandId);
      fetchBrands();
    } catch (e) {
      // Handle error
    }
  }
}
