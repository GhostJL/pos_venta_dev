import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/entities/customer_payment.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getCustomers({
    String? query,
    int? limit,
    int? offset,
    bool showInactive = false,
  });
  Future<int> countCustomers({String? query, bool showInactive = false});
  Future<Customer?> getCustomerById(int id);
  Future<Customer?> getCustomerByCode(String code);
  Future<int> createCustomer(Customer customer);
  Future<int> updateCustomer(Customer customer);
  Future<int> deleteCustomer(int id);
  Future<List<Customer>> searchCustomers(String query);
  Future<String> generateNextCustomerCode();
  Future<bool> isCodeUnique(String code, {int? excludeId});
  Future<void> updateCustomerCredit(
    int customerId,
    double amount, {
    bool isIncrement = true,
  });
  Future<double> getCustomerBalance(int customerId);
  Future<int> registerPayment(CustomerPayment payment);
  Future<List<CustomerPayment>> getPayments(int customerId);
  Future<List<Customer>> getDebtors();
}
