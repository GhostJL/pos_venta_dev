import 'package:posventa/domain/entities/discount.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/presentation/providers/di/discount_di.dart';

part 'discount_provider.g.dart';

@Riverpod(keepAlive: true)
class DiscountList extends _$DiscountList {
  @override
  Future<List<Discount>> build() async {
    final getAllDiscounts = ref.watch(getAllDiscountsUseCaseProvider);
    return getAllDiscounts.execute();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(getAllDiscountsUseCaseProvider).execute();
    });
  }

  Future<void> createDiscount(Discount discount) async {
    await ref.read(createDiscountUseCaseProvider).execute(discount);
    await refresh();
  }

  Future<void> updateDiscount(Discount discount) async {
    await ref.read(updateDiscountUseCaseProvider).execute(discount);
    await refresh();
  }

  Future<void> deleteDiscount(int id) async {
    await ref.read(deleteDiscountUseCaseProvider).execute(id);
    await refresh();
  }
}
