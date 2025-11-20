import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'customer_providers.g.dart';

@riverpod
class CustomerNotifier extends _$CustomerNotifier {
  @override
  Future<List<Customer>> build() async {
    return ref.read(getCustomersUseCaseProvider).call();
  }

  Future<void> addCustomer(Customer customer) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(createCustomerUseCaseProvider).call(customer);
      return ref.read(getCustomersUseCaseProvider).call();
    });
  }

  Future<void> updateCustomer(Customer customer) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateCustomerUseCaseProvider).call(customer);
      return ref.read(getCustomersUseCaseProvider).call();
    });
  }

  Future<void> deleteCustomer(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteCustomerUseCaseProvider).call(id);
      return ref.read(getCustomersUseCaseProvider).call();
    });
  }

  Future<void> searchCustomers(String query) async {
    if (query.isEmpty) {
      state = await AsyncValue.guard(() async {
        return ref.read(getCustomersUseCaseProvider).call();
      });
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(searchCustomersUseCaseProvider).call(query);
    });
  }
}
