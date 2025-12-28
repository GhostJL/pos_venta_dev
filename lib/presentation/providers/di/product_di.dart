import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/entities/unit_of_measure.dart';
import 'package:posventa/domain/repositories/product_repository.dart';
import 'package:posventa/data/repositories/product_repository_impl.dart';
import 'package:posventa/domain/use_cases/product/get_all_products.dart';
import 'package:posventa/domain/use_cases/product/create_product.dart';
import 'package:posventa/domain/use_cases/product/update_product.dart';
import 'package:posventa/domain/use_cases/product/delete_product.dart';
import 'package:posventa/domain/use_cases/product/search_products.dart';
import 'package:posventa/domain/repositories/unit_of_measure_repository.dart';
import 'package:posventa/data/repositories/unit_of_measure_repository_impl.dart';
import 'package:posventa/domain/repositories/tax_rate_repository.dart';
import 'package:posventa/data/repositories/tax_rate_repository_impl.dart';
import 'package:posventa/domain/use_cases/tax_rate/get_all_tax_rates.dart';
import 'package:posventa/domain/use_cases/tax_rate/create_tax_rate.dart';
import 'package:posventa/domain/use_cases/tax_rate/update_tax_rate.dart';
import 'package:posventa/domain/use_cases/tax_rate/delete_tax_rate.dart';
import 'package:posventa/domain/use_cases/tax_rate/set_default_tax_rate.dart';
import 'package:posventa/domain/repositories/department_repository.dart';
import 'package:posventa/data/repositories/department_repository_impl.dart';
import 'package:posventa/domain/use_cases/department/create_department.dart';
import 'package:posventa/domain/use_cases/department/delete_department.dart';
import 'package:posventa/domain/use_cases/department/get_all_departments.dart';
import 'package:posventa/domain/use_cases/department/update_department.dart';
import 'package:posventa/domain/repositories/supplier_repository.dart';
import 'package:posventa/data/repositories/supplier_repository_impl.dart';
import 'package:posventa/domain/use_cases/supplier/create_supplier.dart';
import 'package:posventa/domain/use_cases/supplier/delete_supplier.dart';
import 'package:posventa/domain/use_cases/supplier/get_all_suppliers.dart';
import 'package:posventa/domain/use_cases/supplier/update_supplier.dart';
import 'package:posventa/presentation/providers/di/core_di.dart';
import 'package:posventa/data/datasources/product_local_datasource.dart';
import 'package:posventa/data/datasources/product_local_datasource_impl.dart';

part 'product_di.g.dart';

// --- Product Providers ---

@riverpod
ProductLocalDataSource productLocalDataSource(ref) =>
    ProductLocalDataSourceImpl(ref.watch(databaseHelperProvider));

@riverpod
ProductRepository productRepository(ref) =>
    ProductRepositoryImpl(ref.watch(productLocalDataSourceProvider));

@riverpod
GetAllProducts getAllProducts(ref) =>
    GetAllProducts(ref.watch(productRepositoryProvider));

@riverpod
CreateProduct createProduct(ref) =>
    CreateProduct(ref.watch(productRepositoryProvider));

@riverpod
UpdateProduct updateProduct(ref) =>
    UpdateProduct(ref.watch(productRepositoryProvider));

@riverpod
DeleteProduct deleteProduct(ref) =>
    DeleteProduct(ref.watch(productRepositoryProvider));

@riverpod
SearchProducts searchProducts(ref) =>
    SearchProducts(ref.watch(productRepositoryProvider));

// --- Unit of Measure Providers ---

@riverpod
UnitOfMeasureRepository unitOfMeasureRepository(ref) =>
    UnitOfMeasureRepositoryImpl(ref.watch(databaseHelperProvider));

@riverpod
Future<List<UnitOfMeasure>> unitList(ref) async {
  return ref.watch(unitOfMeasureRepositoryProvider).getAllUnits();
}

// --- Tax Rate Providers ---

@riverpod
TaxRateRepository taxRateRepository(ref) =>
    TaxRateRepositoryImpl(ref.watch(databaseHelperProvider));

@riverpod
GetAllTaxRates getAllTaxRatesUseCase(ref) =>
    GetAllTaxRates(ref.watch(taxRateRepositoryProvider));

@riverpod
CreateTaxRate createTaxRate(ref) =>
    CreateTaxRate(ref.watch(taxRateRepositoryProvider));

@riverpod
UpdateTaxRate updateTaxRate(ref) =>
    UpdateTaxRate(ref.watch(taxRateRepositoryProvider));

@riverpod
DeleteTaxRate deleteTaxRate(ref) =>
    DeleteTaxRate(ref.watch(taxRateRepositoryProvider));

@riverpod
SetDefaultTaxRate setDefaultTaxRate(ref) =>
    SetDefaultTaxRate(ref.watch(taxRateRepositoryProvider));

// --- Department Providers ---

@riverpod
DepartmentRepository departmentRepository(ref) =>
    DepartmentRepositoryImpl(ref.watch(databaseHelperProvider));

@riverpod
GetAllDepartments getAllDepartmentsUseCase(ref) =>
    GetAllDepartments(ref.watch(departmentRepositoryProvider));

@riverpod
CreateDepartment createDepartmentUseCase(ref) =>
    CreateDepartment(ref.watch(departmentRepositoryProvider));

@riverpod
UpdateDepartment updateDepartmentUseCase(ref) =>
    UpdateDepartment(ref.watch(departmentRepositoryProvider));

@riverpod
DeleteDepartment deleteDepartmentUseCase(ref) =>
    DeleteDepartment(ref.watch(departmentRepositoryProvider));

// --- Supplier Providers ---

@riverpod
SupplierRepository supplierRepository(ref) =>
    SupplierRepositoryImpl(ref.watch(databaseHelperProvider));

@riverpod
GetAllSuppliers getAllSuppliersUseCase(ref) =>
    GetAllSuppliers(ref.watch(supplierRepositoryProvider));

@riverpod
CreateSupplier createSupplierUseCase(ref) =>
    CreateSupplier(ref.watch(supplierRepositoryProvider));

@riverpod
UpdateSupplier updateSupplierUseCase(ref) =>
    UpdateSupplier(ref.watch(supplierRepositoryProvider));

@riverpod
DeleteSupplier deleteSupplierUseCase(ref) =>
    DeleteSupplier(ref.watch(supplierRepositoryProvider));
