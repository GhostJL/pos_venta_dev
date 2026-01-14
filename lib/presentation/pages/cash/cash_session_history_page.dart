import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/pages/shared/main_layout.dart';
import 'package:posventa/presentation/providers/cash_session_providers.dart';
import 'package:posventa/presentation/providers/cashier_providers.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/widgets/cash_sessions/cash_session_card.dart';
import 'package:posventa/presentation/widgets/cash_sessions/cash_session_filter_dialog.dart';

class CashSessionHistoryPage extends ConsumerStatefulWidget {
  const CashSessionHistoryPage({super.key});

  @override
  ConsumerState<CashSessionHistoryPage> createState() =>
      _CashSessionHistoryPageState();
}

class _CashSessionHistoryPageState
    extends ConsumerState<CashSessionHistoryPage> {
  int? _selectedUserId;
  int? _selectedWarehouseId;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(cashSessionListProvider(CashSessionFilter()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isCashier = user?.role == UserRole.cajero;

    final effectiveUserId = isCashier ? user!.id : _selectedUserId;

    final filter = CashSessionFilter(
      userId: effectiveUserId,
      warehouseId: _selectedWarehouseId,
      startDate: _selectedDateRange?.start,
      endDate: _selectedDateRange?.end,
    );

    final sessionsAsync = ref.watch(cashSessionListProvider(filter));
    final cashiersAsync = ref.watch(cashierListProvider);
    final warehousesAsync = ref.watch(warehouseListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            final isSmallScreen = MediaQuery.of(context).size.width < 1200;
            return isSmallScreen
                ? IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => MainLayout.of(context)?.openDrawer(),
                  )
                : const SizedBox.shrink(); // Hide if larger
          },
        ),
        title: const Text('Sesiones de Caja'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => CashSessionFilterDialog(
                cashiersAsync: cashiersAsync,
                warehousesAsync: warehousesAsync,
                isCashier: isCashier,
                selectedUserId: _selectedUserId,
                selectedWarehouseId: _selectedWarehouseId,
                selectedDateRange: _selectedDateRange,
                onApply: ({userId, warehouseId, dateRange}) {
                  setState(() {
                    _selectedUserId = userId;
                    _selectedWarehouseId = warehouseId;
                    _selectedDateRange = dateRange;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text('No se encontraron sesiones.'));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // Mobile: List View
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return CashSessionCard(session: sessions[index]);
                  },
                );
              } else {
                // Tablet/Desktop: Grid View
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    mainAxisExtent: 180, // Fixed height for consistency
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    return CashSessionCard(session: sessions[index]);
                  },
                );
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
