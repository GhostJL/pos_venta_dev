import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/repositories/brand_repository_impl.dart';
import 'package:posventa/domain/entities/brand.dart';
import 'package:posventa/domain/repositories/brand_repository.dart';
import 'package:posventa/domain/use_cases/create_brand.dart';
import 'package:posventa/domain/use_cases/delete_brand.dart';
import 'package:posventa/domain/use_cases/get_all_brands.dart';
import 'package:posventa/domain/use_cases/update_brand.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final brandRepositoryProvider = Provider<BrandRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return BrandRepositoryImpl(dbHelper);
});

final getAllBrandsUseCaseProvider = Provider(
  (ref) => GetAllBrands(ref.watch(brandRepositoryProvider)),
);

final createBrandUseCaseProvider = Provider(
  (ref) => CreateBrand(ref.watch(brandRepositoryProvider)),
);

final updateBrandUseCaseProvider = Provider(
  (ref) => UpdateBrand(ref.watch(brandRepositoryProvider)),
);

final deleteBrandUseCaseProvider = Provider(
  (ref) => DeleteBrand(ref.watch(brandRepositoryProvider)),
);

class BrandListNotifier extends StateNotifier<AsyncValue<List<Brand>>> {
  final GetAllBrands _getAllBrands;
  final CreateBrand _createBrand;
  final UpdateBrand _updateBrand;
  final DeleteBrand _deleteBrand;

  BrandListNotifier(
    this._getAllBrands,
    this._createBrand,
    this._updateBrand,
    this._deleteBrand,
  ) : super(const AsyncValue.loading()) {
    loadBrands();
  }

  Future<void> loadBrands() async {
    state = const AsyncValue.loading();
    try {
      final brands = await _getAllBrands();
      state = AsyncValue.data(brands);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> addBrand(Brand brand) async {
    try {
      await _createBrand(brand);
    } finally {
      await loadBrands();
    }
  }

  Future<void> updateBrand(Brand brand) async {
    try {
      await _updateBrand(brand);
    } finally {
      await loadBrands();
    }
  }

  Future<void> deleteBrand(int id) async {
    try {
      await _deleteBrand(id);
    } finally {
      await loadBrands();
    }
  }
}

final brandListProvider =
    StateNotifierProvider<BrandListNotifier, AsyncValue<List<Brand>>>(
  (ref) {
    return BrandListNotifier(
      ref.watch(getAllBrandsUseCaseProvider),
      ref.watch(createBrandUseCaseProvider),
      ref.watch(updateBrandUseCaseProvider),
      ref.watch(deleteBrandUseCaseProvider),
    );
  },
);
