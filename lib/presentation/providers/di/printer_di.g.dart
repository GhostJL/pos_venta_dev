// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'printer_di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(printerService)
const printerServiceProvider = PrinterServiceProvider._();

final class PrinterServiceProvider
    extends $FunctionalProvider<PrinterService, PrinterService, PrinterService>
    with $Provider<PrinterService> {
  const PrinterServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'printerServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$printerServiceHash();

  @$internal
  @override
  $ProviderElement<PrinterService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PrinterService create(Ref ref) {
    return printerService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PrinterService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PrinterService>(value),
    );
  }
}

String _$printerServiceHash() => r'42f6bd6915f7e310e53ce1dd95254906ff2cf7a6';
