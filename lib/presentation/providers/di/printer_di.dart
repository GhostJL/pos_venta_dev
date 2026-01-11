import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/services/printer_service.dart';
import 'package:posventa/data/services/printer_service_impl.dart';

part 'printer_di.g.dart';

@riverpod
PrinterService printerService(Ref ref) {
  return PrinterServiceImpl();
}
