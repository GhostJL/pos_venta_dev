import 'package:posventa/domain/entities/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getCustomers();
  Future<Customer?> getCustomerById(int id);
  Future<Customer?> getCustomerByCode(String code);
  Future<int> createCustomer(Customer customer);
  Future<int> updateCustomer(Customer customer);
  Future<int> deleteCustomer(int id);
  Future<List<Customer>> searchCustomers(String query);
  Future<String> generateNextCustomerCode();
  Future<bool> isCodeUnique(String code, {int? excludeId});
}
