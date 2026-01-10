import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/repositories/customer_repository.dart';
import 'package:posventa/data/repositories/customer_repository_impl.dart';
import 'package:posventa/domain/use_cases/customer/get_customers_use_case.dart';
import 'package:posventa/domain/use_cases/customer/create_customer_use_case.dart';
import 'package:posventa/domain/use_cases/customer/update_customer_use_case.dart';
import 'package:posventa/domain/use_cases/customer/delete_customer_use_case.dart';
import 'package:posventa/domain/use_cases/customer/search_customers_use_case.dart';
import 'package:posventa/domain/use_cases/customer/generate_next_customer_code_use_case.dart';
import 'package:posventa/domain/use_cases/customer/update_customer_credit_use_case.dart';
import 'package:posventa/domain/use_cases/customer/get_customer_balance_use_case.dart';
import 'package:posventa/domain/use_cases/customer/get_customer_by_id_use_case.dart';
import 'package:posventa/presentation/providers/di/core_di.dart';

part 'customer_di.g.dart';

// --- Customer Providers ---

@riverpod
CustomerRepository customerRepository(ref) =>
    CustomerRepositoryImpl(ref.watch(appDatabaseProvider));

@riverpod
GetCustomersUseCase getCustomersUseCase(ref) =>
    GetCustomersUseCase(ref.watch(customerRepositoryProvider));

@riverpod
CreateCustomerUseCase createCustomerUseCase(ref) =>
    CreateCustomerUseCase(ref.watch(customerRepositoryProvider));

@riverpod
UpdateCustomerUseCase updateCustomerUseCase(ref) =>
    UpdateCustomerUseCase(ref.watch(customerRepositoryProvider));

@riverpod
DeleteCustomerUseCase deleteCustomerUseCase(ref) =>
    DeleteCustomerUseCase(ref.watch(customerRepositoryProvider));

@riverpod
SearchCustomersUseCase searchCustomersUseCase(ref) =>
    SearchCustomersUseCase(ref.watch(customerRepositoryProvider));

@riverpod
GenerateNextCustomerCodeUseCase generateNextCustomerCodeUseCase(ref) =>
    GenerateNextCustomerCodeUseCase(ref.watch(customerRepositoryProvider));

@riverpod
UpdateCustomerCreditUseCase updateCustomerCreditUseCase(ref) =>
    UpdateCustomerCreditUseCase(ref.watch(customerRepositoryProvider));

@riverpod
GetCustomerBalanceUseCase getCustomerBalanceUseCase(ref) =>
    GetCustomerBalanceUseCase(ref.watch(customerRepositoryProvider));

@riverpod
GetCustomerByIdUseCase getCustomerByIdUseCase(ref) =>
    GetCustomerByIdUseCase(ref.watch(customerRepositoryProvider));
