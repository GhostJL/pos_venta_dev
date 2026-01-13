import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/presentation/providers/di/customer_di.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'debtors_provider.g.dart';

@riverpod
Future<List<Customer>> debtors(ref) async {
  return ref.watch(getDebtorsUseCaseProvider).call();
}
