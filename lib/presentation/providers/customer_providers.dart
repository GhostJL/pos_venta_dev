import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/presentation/providers/paginated_customers_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'customer_providers.g.dart';

@Riverpod(keepAlive: true)
class CustomerNotifier extends _$CustomerNotifier {
  @override
  Future<List<Customer>> build() async {
    return ref.read(getCustomersUseCaseProvider).call();
  }

  Future<void> addCustomer(Customer customer) async {
    final createUseCase = ref.read(createCustomerUseCaseProvider);
    final getUseCase = ref.read(getCustomersUseCaseProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await createUseCase.call(customer);
      ref.invalidate(paginatedCustomersCountProvider);
      ref.invalidate(paginatedCustomersPageProvider);
      return getUseCase.call();
    });
  }

  Future<void> updateCustomer(Customer customer) async {
    final updateUseCase = ref.read(updateCustomerUseCaseProvider);
    final getUseCase = ref.read(getCustomersUseCaseProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await updateUseCase.call(customer);
      ref.invalidate(paginatedCustomersCountProvider);
      ref.invalidate(paginatedCustomersPageProvider);
      ref.invalidate(customerByIdProvider(customer.id!));
      return getUseCase.call();
    });
  }

  Future<void> deleteCustomer(int id) async {
    final deleteUseCase = ref.read(deleteCustomerUseCaseProvider);
    final getUseCase = ref.read(getCustomersUseCaseProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await deleteUseCase.call(id);
      ref.invalidate(paginatedCustomersCountProvider);
      ref.invalidate(paginatedCustomersPageProvider);
      ref.invalidate(customerByIdProvider(id));
      return getUseCase.call();
    });
  }

  Future<void> searchCustomers(String query) async {
    if (query.isEmpty) {
      final getUseCase = ref.read(getCustomersUseCaseProvider);
      state = await AsyncValue.guard(() async {
        return getUseCase.call();
      });
      return;
    }
    final searchUseCase = ref.read(searchCustomersUseCaseProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return searchUseCase.call(query);
    });
  }

  Future<void> payDebt(int customerId, double amount) async {
    final updateCreditUseCase = ref.read(updateCustomerCreditUseCaseProvider);
    final getUseCase = ref.read(getCustomersUseCaseProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await updateCreditUseCase.call(customerId, amount, isIncrement: false);
      // Refresh list
      ref.invalidate(paginatedCustomersCountProvider);
      ref.invalidate(paginatedCustomersPageProvider);
      ref.invalidate(customerByIdProvider(customerId));
      return getUseCase.call();
    });
  }
}

@riverpod
Future<Customer?> customerById(Ref ref, int id) async {
  // Use keepAlive to avoid refetching immediately if navigating back/forth
  final link = ref.keepAlive();
  // Cancel the link when the provider is no longer used (optional, or set a timer)
  // For now, simple keepAlive
  return ref.watch(getCustomerByIdUseCaseProvider).call(id);
}
