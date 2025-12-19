import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/layouts/permission_denied_widget.dart';
import 'package:posventa/presentation/widgets/sales/history/sales_card_history_widget.dart';
import 'package:posventa/presentation/widgets/common/filters/date_range_filter.dart';
import 'package:posventa/presentation/widgets/common/async_value_handler.dart';
import 'package:posventa/presentation/widgets/common/empty_state_widget.dart';

class SalesHistoryPage extends ConsumerStatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  ConsumerState<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends ConsumerState<SalesHistoryPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(salesListStreamProvider);
    });
  }

  void _onDateRangeChanged(DateTime? start, DateTime? end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasViewPermission = ref.watch(
      hasPermissionProvider(PermissionConstants.reportsView),
    );

    final salesAsync = ref.watch(
      salesListStreamProvider((startDate: _startDate, endDate: _endDate)),
    );

    if (!hasViewPermission) {
      return PermissionDeniedWidget(
        message:
            'No puedes entrar a este módulo.\n\nContacta a un administrador para obtener acceso.',
        icon: Icons.assessment_outlined,
        backRoute: '/home',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ventas'),
        forceMaterialTransparency: true,
        actions: [
          DateRangeFilter(
            startDate: _startDate,
            endDate: _endDate,
            onDateRangeChanged: _onDateRangeChanged,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AsyncValueHandler(
        value: salesAsync,
        data: (sales) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sales.length,
          itemBuilder: (context, index) {
            final sale = sales[index];
            return SaleCardHistoryWidget(sale: sale);
          },
        ),
        emptyState: EmptyStateWidget(
          icon: Icons.receipt_long_outlined,
          message: _startDate != null && _endDate != null
              ? 'No hay ventas en este rango de fechas'
              : 'No hay ventas registradas',
        ),
        enableRefresh: true,
        onRefresh: () async {
          ref.invalidate(salesListStreamProvider);
        },
        onRetry: () => ref.invalidate(salesListStreamProvider),
      ),
    );
  }
}
