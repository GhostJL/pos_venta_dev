import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/core/utils/file_manager_service.dart';
import 'package:posventa/domain/services/printer_service.dart';
import 'package:posventa/features/sales/domain/models/ticket_data.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';
import 'package:posventa/presentation/providers/settings_provider.dart';
import 'package:printing/printing.dart';
import 'package:posventa/presentation/widgets/pos/payment/widgets/numeric_keypad.dart';
import 'package:posventa/presentation/widgets/pos/payment/widgets/payment_action_buttons.dart';
import 'package:posventa/presentation/widgets/pos/payment/widgets/payment_change_display.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  String _selectedPaymentMethod = 'Efectivo';
  String _amountInput = '0'; // Use String for easier keypad manipulation
  double _change = 0.0;

  final List<double> _frequentValues = [20, 50, 100, 200, 500];

  late TextEditingController _mobileAmountController;
  final FocusNode _mobileFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _mobileAmountController = TextEditingController(text: _amountInput);
    // Initialize with 0 or empty, waiting for user input or "Exact Amount" tap
  }

  @override
  void dispose() {
    _mobileAmountController.dispose();
    _mobileFocusNode.dispose();
    super.dispose();
  }

  void _updateAmount(String newVal) {
    setState(() {
      _amountInput = newVal;
      // Sync controller if the update didn't come from the controller itself
      // (simple check to avoid cursor jumping loops, handled in onChanged usually)
      if (_mobileAmountController.text != newVal) {
        _mobileAmountController.text = newVal;
        // Move cursor to end
        _mobileAmountController.selection = TextSelection.fromPosition(
          TextPosition(offset: _mobileAmountController.text.length),
        );
      }
      _calculateChange();
    });
  }

  void _onMobileInputChanged(String val) {
    // Determine if we need to filter characters
    String filtered = val.replaceAll(RegExp(r'[^0-9.]'), '');

    // Validate decimals
    if (filtered.contains('.')) {
      final parts = filtered.split('.');
      if (parts.length > 2) {
        // More than one dot, keep only the first part and the first dot
        filtered = '${parts[0]}.${parts.sublist(1).join('')}';
      }
      if (parts.length > 1 && parts[1].length > 2) {
        // Limit to 2 decimal places
        filtered = '${parts[0]}.${parts[1].substring(0, 2)}';
      }
    }

    setState(() {
      _amountInput = filtered.isEmpty ? '0' : filtered;
      _calculateChange();
    });
  }

  void _onKeyPress(String key) {
    if (_amountInput == '0' && key != '.') {
      _updateAmount(key);
    } else {
      if (key == '.' && _amountInput.contains('.')) return;
      // Prevent too many decimals
      if (_amountInput.contains('.')) {
        final parts = _amountInput.split('.');
        if (parts.length > 1 && parts[1].length >= 2) return;
      }
      _updateAmount(_amountInput + key);
    }
  }

  void _onDelete() {
    if (_amountInput.isNotEmpty) {
      if (_amountInput.length == 1) {
        _updateAmount('0');
      } else {
        _updateAmount(_amountInput.substring(0, _amountInput.length - 1));
      }
    }
  }

  void _onClear() {
    _updateAmount('0');
    // Request focus back on mobile field if cleared
    if (_mobileFocusNode.canRequestFocus) {
      _mobileFocusNode.requestFocus();
    }
  }

  void _calculateChange() {
    final total = ref.read(pOSProvider).total;
    final amountPaid = double.tryParse(_amountInput) ?? 0.0;
    _change = amountPaid - total;
  }

  void _setAmount(double value) {
    // Format: remove decimals if whole number (e.g. 50.0 -> "50", 50.5 -> "50.50")
    String formatted;
    if (value % 1 == 0) {
      formatted = value.toInt().toString();
    } else {
      formatted = value.toStringAsFixed(2);
    }
    _updateAmount(formatted);
  }

  void _handleConfirmPayment(double total) {
    final amountPaid = double.tryParse(_amountInput) ?? 0.0;
    if (amountPaid < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('El monto recibido es insuficiente'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ref
        .read(pOSProvider.notifier)
        .completeSale(_selectedPaymentMethod, amountPaid);
  }

  Future<void> _savePdfFallback(
    BuildContext context,
    PrinterService printerService,
    TicketData ticketData,
    dynamic settings,
    String message,
  ) async {
    try {
      final pdfPath =
          settings.pdfSavePath ??
          await FileManagerService.getDefaultPdfSavePath();
      final savedPath = await printerService.savePdfTicket(ticketData, pdfPath);

      // Only log success, don't show snackbar (would be annoying on every sale)
      debugPrint('PDF guardado exitosamente: $savedPath');
    } catch (e) {
      debugPrint('Error saving PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar PDF: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final posState = ref.watch(pOSProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final total = posState.total;

    ref.listen(pOSProvider, (previous, next) async {
      if (next.successMessage != null && next.successMessage!.isNotEmpty) {
        // Print/Save Ticket
        if (next.lastCompletedSale != null) {
          final sale = next.lastCompletedSale!;
          final printerService = ref.read(printerServiceProvider);

          // Get saved printer and settings
          final settings = await ref.read(settingsProvider.future);
          final printerName = settings.printerName;
          final enablePrinting = settings.enableSalesPrinting;

          final ticketData = TicketData(
            sale: sale,
            items: sale.items,
            storeName: 'Mi Tienda POS',
            storeAddress: 'Ubicación General',
          );

          try {
            if (enablePrinting) {
              // Printing is enabled, check if we have a valid printer
              Printer? targetPrinter;
              bool printerAvailable = false;

              if (printerName != null) {
                try {
                  final printers = await printerService.getPrinters();
                  targetPrinter = printers
                      .where((p) => p.name == printerName)
                      .firstOrNull;

                  // Check if printer was found and is not a PDF virtual printer
                  if (targetPrinter != null) {
                    // Filter out common PDF virtual printers
                    final lowerName = targetPrinter.name.toLowerCase();
                    final isPdfPrinter =
                        lowerName.contains('pdf') ||
                        lowerName.contains('microsoft print to pdf') ||
                        lowerName.contains('adobe pdf') ||
                        lowerName.contains('foxit') ||
                        lowerName.contains('cutepdf') ||
                        lowerName.contains('novapdf');

                    printerAvailable = !isPdfPrinter;
                  }
                } catch (e) {
                  debugPrint('Error loading printers for auto-print: $e');
                }
              }

              if (printerAvailable && targetPrinter != null) {
                // We have a physical printer configured
                if (Platform.isAndroid) {
                  // Android: Try to print, save PDF only if fails
                  try {
                    await printerService.printTicket(
                      ticketData,
                      printer: targetPrinter,
                    );
                  } catch (printError) {
                    debugPrint('Print error: $printError');
                    if (settings.autoSavePdfWhenPrintDisabled) {
                      if (context.mounted) {
                        await _savePdfFallback(
                          context,
                          printerService,
                          ticketData,
                          settings,
                          'No se pudo imprimir. Ticket guardado como PDF.',
                        );
                      }
                    }
                  }
                } else {
                  // Desktop: Print AND save PDF (can't verify if printer is actually connected)
                  // Attempt to print (will queue if printer available)
                  try {
                    await printerService.printTicket(
                      ticketData,
                      printer: targetPrinter,
                    );
                  } catch (printError) {
                    debugPrint('Print error: $printError');
                  }

                  // Always save PDF as backup on Desktop
                  if (settings.autoSavePdfWhenPrintDisabled) {
                    if (context.mounted) {
                      await _savePdfFallback(
                        context,
                        printerService,
                        ticketData,
                        settings,
                        'Ticket guardado como PDF.',
                      );
                    }
                  }
                }
              } else {
                // No physical printer available, save as PDF
                if (settings.autoSavePdfWhenPrintDisabled) {
                  if (context.mounted) {
                    await _savePdfFallback(
                      context,
                      printerService,
                      ticketData,
                      settings,
                      'Sin impresora física disponible. Ticket guardado como PDF.',
                    );
                  }
                }
              }
            } else {
              // Printing is disabled, save as PDF
              if (settings.autoSavePdfWhenPrintDisabled) {
                if (context.mounted) {
                  await _savePdfFallback(
                    context,
                    printerService,
                    ticketData,
                    settings,
                    'Ticket guardado como PDF',
                  );
                }
              }
            }
          } catch (e) {
            debugPrint('Error in print/save flow: $e');
          }
        }

        if (context.mounted) {
          context.go('/sales');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.successMessage!),
              backgroundColor: AppTheme.transactionSuccess,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): () => context.pop(),
        const SingleActivator(LogicalKeyboardKey.enter): () {
          if (!posState.isLoading && _change >= 0) {
            _handleConfirmPayment(posState.total);
          }
        },
        const SingleActivator(LogicalKeyboardKey.numpadEnter): () {
          if (!posState.isLoading && _change >= 0) {
            _handleConfirmPayment(posState.total);
          }
        },
        const SingleActivator(LogicalKeyboardKey.backspace): _onDelete,
      },
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            final char = event.character;
            if (char != null && RegExp(r'[0-9.]').hasMatch(char)) {
              _onKeyPress(char);
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            title: Text(
              'Procesar Pago',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: theme.colorScheme.surface,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.pop(),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 800;
              final screenHeight = MediaQuery.of(context).size.height;
              // Dynamically adjust keypad height based on screen height for small devices
              final keypadHeight = screenHeight < 700 ? 240.0 : 280.0;

              if (isMobile) {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 12),
                            // Total Display (Compact)
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    'Total a Pagar',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '\$${total.toStringAsFixed(2)}',
                                    style: theme.textTheme.displaySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: colorScheme.primary,
                                          fontSize: 32,
                                        ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Payment Methods (Compact Row)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _PaymentMethodChip(
                                    label: 'Efectivo',
                                    icon: Icons.payments_outlined,
                                    isSelected:
                                        _selectedPaymentMethod == 'Efectivo',
                                    onTap: () => setState(
                                      () => _selectedPaymentMethod = 'Efectivo',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _PaymentMethodChip(
                                    label: 'Tarjeta',
                                    icon: Icons.credit_card_outlined,
                                    isSelected:
                                        _selectedPaymentMethod == 'Tarjeta',
                                    onTap: () => setState(
                                      () => _selectedPaymentMethod = 'Tarjeta',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _PaymentMethodChip(
                                    label: 'Transf.',
                                    icon: Icons.account_balance_wallet_outlined,
                                    isSelected:
                                        _selectedPaymentMethod ==
                                        'Transferencia',
                                    onTap: () => setState(
                                      () => _selectedPaymentMethod =
                                          'Transferencia',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _PaymentMethodChip(
                                    label: 'Crédito',
                                    icon: Icons.credit_score_outlined,
                                    isSelected:
                                        _selectedPaymentMethod == 'Crédito',
                                    onTap: () => setState(
                                      () => _selectedPaymentMethod = 'Crédito',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Input Field
                            TextField(
                              controller: _mobileAmountController,
                              focusNode: _mobileFocusNode,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onChanged: _onMobileInputChanged,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Monto Recibido',
                                prefixText: '\$ ',
                                prefixStyle: theme.textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: _amountInput != '0'
                                    ? IconButton(
                                        icon: const Icon(Icons.cancel),
                                        onPressed: _onClear,
                                      )
                                    : null,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Quick Actions (Wrap - No Scroll)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                _QuickAmountChip(
                                  label: 'Exacto',
                                  amount: total,
                                  currentInput: _amountInput,
                                  onSelected: () => _setAmount(total),
                                  isExactOption: true,
                                ),
                                ..._frequentValues.map(
                                  (value) => _QuickAmountChip(
                                    label: '\$${value.toInt()}',
                                    amount: value,
                                    currentInput: _amountInput,
                                    onSelected: () => _setAmount(value),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Change Display (Compact Row)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: _change < 0
                                    ? colorScheme.errorContainer
                                    : colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _change < 0
                                      ? Colors.transparent
                                      : colorScheme.outlineVariant,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Cambio',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: _change < 0
                                              ? colorScheme.onErrorContainer
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  Text(
                                    '\$${_change.abs().toStringAsFixed(2)}',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: _change < 0
                                              ? colorScheme.onErrorContainer
                                              : colorScheme.onSurface,
                                        ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Pay Button
                            SizedBox(
                              height: 56,
                              width: double.infinity,
                              child: PaymentActionButtons(
                                onCancel: () => context.pop(),
                                onConfirm: posState.isLoading || _change < 0
                                    ? null
                                    : () =>
                                          _handleConfirmPayment(posState.total),
                                isLoading: posState.isLoading,
                                showCancel: false,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              // TABLET LAYOUT (Existing Split View)
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // LEFT COLUMN: Summary & Input Display
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: colorScheme.surfaceContainerLow.withValues(
                        alpha: 0.5,
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // TOTAL DISPLAY
                          Column(
                            children: [
                              Text(
                                'Total a Pagar',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${total.toStringAsFixed(2)}',
                                style: theme.textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.primary,
                                  fontSize: 48,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 48),

                          // RECEIVED AMOUNT DISPLAY
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Monto Recibido',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '\$ $_amountInput',
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
                                          ),
                                    ),
                                    if (_amountInput != '0')
                                      IconButton(
                                        onPressed: _onClear,
                                        icon: const Icon(Icons.clear),
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // CHANGE DISPLAY
                          PaymentChangeDisplay(change: _change),

                          const Spacer(),

                          // PAYMENT METHODS
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _PaymentMethodChip(
                                  label: 'Efectivo',
                                  icon: Icons.payments_outlined,
                                  isSelected:
                                      _selectedPaymentMethod == 'Efectivo',
                                  onTap: () => setState(
                                    () => _selectedPaymentMethod = 'Efectivo',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _PaymentMethodChip(
                                  label: 'Tarjeta',
                                  icon: Icons.credit_card_outlined,
                                  isSelected:
                                      _selectedPaymentMethod == 'Tarjeta',
                                  onTap: () => setState(
                                    () => _selectedPaymentMethod = 'Tarjeta',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _PaymentMethodChip(
                                  label: 'Transf.',
                                  icon: Icons.account_balance_wallet_outlined,
                                  isSelected:
                                      _selectedPaymentMethod == 'Transferencia',
                                  onTap: () => setState(
                                    () => _selectedPaymentMethod =
                                        'Transferencia',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _PaymentMethodChip(
                                  label: 'Crédito',
                                  icon: Icons.credit_score_outlined,
                                  isSelected:
                                      _selectedPaymentMethod == 'Crédito',
                                  onTap: () => setState(
                                    () => _selectedPaymentMethod = 'Crédito',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // RIGHT COLUMN: Keypad & Quick Actions
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border(
                          left: BorderSide(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // QUICK ACTIONS (Grid for Tablet)
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 2.5,
                            children: [
                              _QuickAmountChip(
                                label: 'Exacto',
                                amount: total,
                                currentInput: _amountInput,
                                onSelected: () => _setAmount(total),
                                isExactOption: true,
                                isLarge: true,
                              ),
                              ..._frequentValues.map(
                                (value) => _QuickAmountChip(
                                  label: '\$${value.toInt()}',
                                  amount: value,
                                  currentInput: _amountInput,
                                  onSelected: () => _setAmount(value),
                                  isLarge: true,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // KEYPAD
                          NumericKeypad(
                            onKeyPress: _onKeyPress,
                            onDelete: _onDelete,
                            onClear: _onClear,
                          ),

                          const SizedBox(height: 24),

                          // PAY BUTTON
                          SizedBox(
                            height: 56,
                            child: PaymentActionButtons(
                              onCancel: () => context.pop(),
                              onConfirm: posState.isLoading || _change < 0
                                  ? null
                                  : () => _handleConfirmPayment(posState.total),
                              isLoading: posState.isLoading,
                              showCancel:
                                  false, // Only show Payment button here
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  final String label;
  final double amount;
  final String currentInput;
  final VoidCallback onSelected;
  final bool isExactOption;
  final bool isLarge;

  const _QuickAmountChip({
    required this.label,
    required this.amount,
    required this.currentInput,
    required this.onSelected,
    this.isExactOption = false,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Check if this chip's amount matches the input
    final isSelected = double.tryParse(currentInput) == amount;

    // Common Styles
    final backgroundColor = isSelected
        ? colorScheme.primary
        : colorScheme.surface;
    final foregroundColor = isSelected
        ? colorScheme.onPrimary
        : (isExactOption ? colorScheme.primary : colorScheme.onSurface);
    final borderColor = isSelected
        ? Colors.transparent
        : (isExactOption ? colorScheme.primary : colorScheme.outlineVariant);
    final fontWeight = isSelected || isExactOption
        ? FontWeight.bold
        : FontWeight.w600;

    if (isLarge) {
      return InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: isExactOption ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isExactOption) ...[
                Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: foregroundColor,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: fontWeight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // "Exacto" chip special style (Mobile/Default)
    if (isExactOption) {
      return ActionChip(
        label: Text(label),
        avatar: Icon(
          Icons.check_circle_outline,
          size: 16,
          color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
        ),
        onPressed: onSelected,
        backgroundColor: isSelected ? colorScheme.primary : colorScheme.surface,
        labelStyle: TextStyle(
          color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
        side: isSelected
            ? BorderSide.none
            : BorderSide(color: colorScheme.primary),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );
    }

    // Regular Amount Chips (Fast Cash)
    // Updated to use Primary (Blue) when selected
    return ActionChip(
      label: Text(label),
      onPressed: onSelected,
      backgroundColor: isSelected ? colorScheme.primary : colorScheme.surface,
      side: isSelected
          ? BorderSide.none
          : BorderSide(color: colorScheme.outlineVariant),
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _PaymentMethodChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
