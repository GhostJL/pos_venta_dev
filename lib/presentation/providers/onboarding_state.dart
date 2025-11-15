import 'package:flutter_riverpod/legacy.dart';
import 'package:myapp/domain/entities/user.dart';

class OnboardingState {
  final User? adminUser;
  final String? adminPassword; // Added to hold the raw password temporarily
  final List<User> cashiers;
  final String? pin;

  OnboardingState({
    this.adminUser,
    this.adminPassword,
    this.cashiers = const [],
    this.pin,
  });

  OnboardingState copyWith({
    User? adminUser,
    String? adminPassword,
    List<User>? cashiers,
    String? pin,
  }) {
    return OnboardingState(
      adminUser: adminUser ?? this.adminUser,
      adminPassword: adminPassword ?? this.adminPassword,
      cashiers: cashiers ?? this.cashiers,
      pin: pin ?? this.pin,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(OnboardingState());

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

  void setPin(String pin) {
    state = state.copyWith(pin: pin);
  }

  void reset() {
    state = OnboardingState();
  }
}

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
      return OnboardingNotifier();
    });
