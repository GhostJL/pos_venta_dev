import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/entities/user.dart';

part 'onboarding_state.g.dart';

class OnboardingState {
  final User? adminUser;
  final String? adminPassword;
  final List<User> cashiers;
  final String? accessKey; // Changed from pin to accessKey

  OnboardingState({
    this.adminUser,
    this.adminPassword,
    this.cashiers = const [],
    this.accessKey, // Changed from pin to accessKey
  });

  OnboardingState copyWith({
    User? adminUser,
    String? adminPassword,
    List<User>? cashiers,
    String? accessKey, // Changed from pin to accessKey
  }) {
    return OnboardingState(
      adminUser: adminUser ?? this.adminUser,
      adminPassword: adminPassword ?? this.adminPassword,
      cashiers: cashiers ?? this.cashiers,
      accessKey: accessKey ?? this.accessKey, // Changed from pin to accessKey
    );
  }
}

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingState build() {
    return OnboardingState();
  }

  void setAdmin(User admin, String password) {
    state = state.copyWith(adminUser: admin, adminPassword: password);
  }

  void addCashier(User cashier) {
    state = state.copyWith(cashiers: [...state.cashiers, cashier]);
  }

  void removeCashier(User cashier) {
    state = state.copyWith(
      cashiers: state.cashiers.where((c) => c.id != cashier.id).toList(),
    );
  }

  void setAccessKey(String key) {
    state = state.copyWith(accessKey: key);
  }

  void reset() {
    state = OnboardingState();
  }
}
