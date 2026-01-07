import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final bool useInventory;
  final bool useTax;

  const AppSettings({required this.useInventory, required this.useTax});

  factory AppSettings.defaults() {
    return const AppSettings(useInventory: true, useTax: true);
  }

  AppSettings copyWith({bool? useInventory, bool? useTax}) {
    return AppSettings(
      useInventory: useInventory ?? this.useInventory,
      useTax: useTax ?? this.useTax,
    );
  }

  @override
  List<Object?> get props => [useInventory, useTax];
}
