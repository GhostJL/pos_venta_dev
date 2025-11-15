import 'package:flutter_riverpod/legacy.dart';
import 'package:myapp/domain/entities/user.dart';

class OnboardingState {
  final User? admin;
  final List<User> cashiers;
  final String? pin;

  OnboardingState({this.admin, this.cashiers = const [], this.pin});

  OnboardingState copyWith({User? admin, List<User>? cashiers, String? pin}) {
    return OnboardingState(
      admin: admin ?? this.admin,
      cashiers: cashiers ?? this.cashiers,
      pin: pin ?? this.pin,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(OnboardingState());

  void setAdmin(User admin) {
    state = state.copyWith(admin: admin);
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
