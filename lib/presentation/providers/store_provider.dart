import 'package:posventa/domain/entities/store.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'store_provider.g.dart';

@riverpod
class StoreNotifier extends _$StoreNotifier {
  @override
  Future<Store?> build() async {
    return ref.watch(storeRepositoryProvider).getStore();
  }

  Future<void> updateStore(Store store) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(storeRepositoryProvider).updateStore(store);
      state = AsyncValue.data(store);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
