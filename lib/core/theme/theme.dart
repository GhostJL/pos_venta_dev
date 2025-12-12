import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sistema de Diseño para POS (Punto de Venta)
/// Colorimetría enfocada en la funcionalidad y psicología del retail
class AppTheme {
  // COLORES PRIMARIOS - Identidad de Marca

  /// Color principal del negocio - Usado en header, botones principales
  /// Representa confianza y profesionalismo en transacciones
  static const Color brandPrimary = Color(0xFF1E40AF); // Azul corporativo
  static const Color onBrandPrimary = Color(0xFFFFFFFF);

  /// Color secundario - Acciones complementarias, destacados sutiles
  static const Color brandSecondary = Color(0xFF7C3AED); // Púrpura sofisticado
  static const Color onBrandSecondary = Color(0xFFFFFFFF);

  /// Color terciario - Elementos decorativos, badges informativos
  static const Color brandTertiary = Color(0xFF0891B2); // Cyan profesional
  static const Color onBrandTertiary = Color(0xFFFFFFFF);

  // COLORES TRANSACCIONALES - Estados de Operación

  /// AGREGAR AL CARRITO - Verde confiable para añadir productos
  /// Psicología: Acción positiva, avanzar en el proceso
  static const Color actionAddToCart = Color(0xFF059669);
  static const Color onActionAddToCart = Color(0xFFFFFFFF);

  /// PAGO EXITOSO - Verde brillante para confirmaciones de pago
  /// Psicología: Éxito, transacción completada, todo está bien
  static const Color transactionSuccess = Color(0xFF10B981);
  static const Color onTransactionSuccess = Color(0xFFFFFFFF);

  /// PAGO PENDIENTE - Ámbar para pagos en proceso o por confirmar
  /// Psicología: Atención requerida, en espera, precaución
  static const Color transactionPending = Color(0xFFF59E0B);
  static const Color onTransactionPending = Color(0xFF1E1E1E);

  /// PAGO RECHAZADO - Rojo para transacciones fallidas o canceladas
  /// Psicología: Error, detener acción, requiere corrección
  static const Color transactionFailed = Color(0xFFDC2626);
  static const Color onTransactionFailed = Color(0xFFFFFFFF);

  /// REEMBOLSO - Naranja para devoluciones y reembolsos
  /// Psicología: Acción reversible, movimiento de dinero hacia atrás
  static const Color transactionRefund = Color(0xFFF97316);
  static const Color onTransactionRefund = Color(0xFFFFFFFF);

  // COLORES DE PRODUCTOS - Categorización Visual

  /// PRODUCTO EN STOCK - Verde para disponibilidad inmediata
  /// Indica que el producto puede venderse sin problemas
  static const Color productInStock = Color(0xFF10B981);
  static const Color onProductInStock = Color(0xFFFFFFFF);

  /// STOCK BAJO - Naranja para advertencia de inventario limitado
  /// Alerta al cajero que debe notificar al gerente o hacer pedido
  static const Color productLowStock = Color(0xFFF97316);
  static const Color onProductLowStock = Color(0xFFFFFFFF);

  /// SIN STOCK - Rojo para productos agotados
  /// No se puede vender, debe ofrecerse alternativa
  static const Color productOutOfStock = Color(0xFFEF4444);
  static const Color onProductOutOfStock = Color(0xFFFFFFFF);

  /// PRODUCTO PREMIUM - Dorado para artículos de alta gama
  /// Comunica valor, exclusividad, margen alto
  static const Color productPremium = Color(0xFFD97706);
  static const Color onProductPremium = Color(0xFFFFFFFF);

  /// EN PROMOCIÓN - Magenta vibrante para ofertas y descuentos
  /// Llama la atención, impulsa ventas, comunica oportunidad
  static const Color productOnSale = Color(0xFFDB2777);
  static const Color onProductOnSale = Color(0xFFFFFFFF);

  /// NUEVO PRODUCTO - Azul eléctrico para lanzamientos recientes
  /// Genera interés, comunica novedad, producto a destacar
  static const Color productNew = Color(0xFF3B82F6);
  static const Color onProductNew = Color(0xFFFFFFFF);

  // COLORES DE CLIENTES - Segmentación y Lealtad

  /// CLIENTE VIP - Dorado premium para clientes de alto valor
  /// Tratamiento especial, descuentos exclusivos, prioridad
  static const Color customerVIP = Color(0xFFEAB308);
  static const Color onCustomerVIP = Color(0xFF1E1E1E);

  /// CLIENTE FRECUENTE - Púrpura para compradores regulares
  /// Programa de lealtad activo, historial positivo
  static const Color customerLoyal = Color(0xFF9333EA);
  static const Color onCustomerLoyal = Color(0xFFFFFFFF);

  /// CLIENTE NUEVO - Cyan para primera compra
  /// Oportunidad de crear buena impresión, explicar beneficios
  static const Color customerNew = Color(0xFF06B6D4);
  static const Color onCustomerNew = Color(0xFFFFFFFF);

  /// CLIENTE CON CRÉDITO - Verde para clientes con crédito aprobado
  /// Puede comprar a cuenta, pago diferido disponible
  static const Color customerWithCredit = Color(0xFF059669);
  static const Color onCustomerWithCredit = Color(0xFFFFFFFF);

  /// CLIENTE MOROSO - Rojo para clientes con pagos pendientes
  /// No otorgar más crédito, cobro prioritario
  static const Color customerDelinquent = Color(0xFFDC2626);
  static const Color onCustomerDelinquent = Color(0xFFFFFFFF);

  // COLORES DE MÉTODOS DE PAGO - Identificación Rápida

  /// EFECTIVO - Verde dinero para pagos en efectivo
  /// Pago inmediato, requiere cambio, va a caja física
  static const Color paymentCash = Color(0xFF10B981);
  static const Color onPaymentCash = Color(0xFFFFFFFF);

  /// TARJETA - Azul corporativo para tarjetas débito/crédito
  /// Pago electrónico, requiere terminal, sin cambio
  static const Color paymentCard = Color(0xFF3B82F6);
  static const Color onPaymentCard = Color(0xFFFFFFFF);

  /// TRANSFERENCIA - Púrpura tech para pagos digitales/transferencias
  /// Pago por app bancaria, requiere confirmación
  static const Color paymentTransfer = Color(0xFF8B5CF6);
  static const Color onPaymentTransfer = Color(0xFFFFFFFF);

  /// WALLET DIGITAL - Cyan moderno para pagos móviles (Apple Pay, etc)
  /// Tecnología contactless, rápido, sin PIN
  static const Color paymentDigitalWallet = Color(0xFF06B6D4);
  static const Color onPaymentDigitalWallet = Color(0xFFFFFFFF);

  /// CRÉDITO DE TIENDA - Naranja para crédito interno
  /// Pago diferido, requiere autorización, generar documento
  static const Color paymentStoreCredit = Color(0xFFF97316);
  static const Color onPaymentStoreCredit = Color(0xFFFFFFFF);

  // COLORES DE MÉTRICAS - Dashboard y Reportes

  /// VENTAS DEL DÍA - Verde crecimiento para ingresos
  /// Número positivo, meta del día, rendimiento de ventas
  static const Color metricDailySales = Color(0xFF10B981);
  static const Color onMetricDailySales = Color(0xFFFFFFFF);

  /// GASTOS/EGRESOS - Rojo para salida de dinero
  /// Compras, pagos a proveedores, reducción de caja
  static const Color metricExpenses = Color(0xFFEF4444);
  static const Color onMetricExpenses = Color(0xFFFFFFFF);

  /// UTILIDAD/GANANCIA - Púrpura premium para margen neto
  /// El objetivo final, lo que realmente ganó el negocio
  static const Color metricProfit = Color(0xFF7C3AED);
  static const Color onMetricProfit = Color(0xFFFFFFFF);

  /// FLUJO DE CAJA - Azul liquidez para dinero disponible
  /// Efectivo en caja, capital de trabajo, solvencia
  static const Color metricCashFlow = Color(0xFF0EA5E9);
  static const Color onMetricCashFlow = Color(0xFFFFFFFF);

  /// META/OBJETIVO - Ámbar para targets y objetivos
  /// Cifra a alcanzar, motivación del equipo, benchmark
  static const Color metricTarget = Color(0xFFF59E0B);
  static const Color onMetricTarget = Color(0xFF1E1E1E);

  // COLORES DE ALERTAS - Notificaciones del Sistema

  /// ALERTA CRÍTICA - Rojo intenso para problemas urgentes
  /// Caja descuadrada, error de sistema, requiere atención inmediata
  static const Color alertCritical = Color(0xFFDC2626);
  static const Color onAlertCritical = Color(0xFFFFFFFF);

  /// ADVERTENCIA - Ámbar para situaciones que requieren atención
  /// Stock bajo, cierre de turno pendiente, revisar antes de continuar
  static const Color alertWarning = Color(0xFFF59E0B);
  static const Color onAlertWarning = Color(0xFF1E1E1E);

  /// INFORMACIÓN - Azul para mensajes informativos
  /// Tips, recordatorios, información general no urgente
  static const Color alertInfo = Color(0xFF3B82F6);
  static const Color onAlertInfo = Color(0xFFFFFFFF);

  /// ÉXITO - Verde para confirmaciones positivas
  /// Operación completada, todo correcto, puede continuar
  static const Color alertSuccess = Color(0xFF10B981);
  static const Color onAlertSuccess = Color(0xFFFFFFFF);

  // COLORES DE ACCIONES - Botones de Operación Rápida

  /// ACCIÓN CONFIRMAR - Verde para botones de confirmación
  /// Proceder con venta, aceptar pago, finalizar operación
  static const Color actionConfirm = Color(0xFF10B981);
  static const Color onActionConfirm = Color(0xFFFFFFFF);

  /// ACCIÓN CANCELAR - Rojo para cancelación de operaciones
  /// Anular venta, rechazar operación, volver atrás
  static const Color actionCancel = Color(0xFFEF4444);
  static const Color onActionCancel = Color(0xFFFFFFFF);

  /// ACCIÓN PAUSAR - Ámbar para operaciones en espera
  /// Suspender venta, guardar para después, cliente vuelve
  static const Color actionPause = Color(0xFFF59E0B);
  static const Color onActionPause = Color(0xFF1E1E1E);

  /// ACCIÓN EDITAR - Azul para modificar información
  /// Cambiar cantidad, editar precio, ajustar datos
  static const Color actionEdit = Color(0xFF3B82F6);
  static const Color onActionEdit = Color(0xFFFFFFFF);

  /// ACCIÓN ELIMINAR - Rojo oscuro para borrar elementos
  /// Quitar del carrito, eliminar producto, borrar registro
  static const Color actionDelete = Color(0xFF991B1B);
  static const Color onActionDelete = Color(0xFFFFFFFF);

  /// ACCIÓN IMPRIMIR - Gris para generar comprobantes
  /// Ticket, factura, reporte, neutro y funcional
  static const Color actionPrint = Color(0xFF475569);
  static const Color onActionPrint = Color(0xFFFFFFFF);

  // COLORES DE SUPERFICIE - Fondos y Contenedores

  /// Superficies Light Mode
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceContainerLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerHighLight = Color(0xFFF5F5F5);
  static const Color surfaceContainerLowLight = Color(0xFFFCFCFC);

  /// Superficies Dark Mode
  static const Color surfaceDark = Color(0xFF0F0F0F);
  static const Color surfaceContainerDark = Color(0xFF1A1A1A);
  static const Color surfaceContainerHighDark = Color(0xFF2A2A2A);
  static const Color surfaceContainerLowDark = Color(0xFF141414);

  // COLORES DE BORDE Y DIVISIÓN
  static const Color borderLight = Color(0xFFE5E5E5);
  static const Color borderDark = Color(0xFF2A2A2A);
  static const Color dividerLight = Color(0xFFE5E5E5);
  static const Color dividerDark = Color(0xFF2A2A2A);

  // COLORES DE TEXTO
  static const Color textPrimaryLight = Color(0xFF171717);
  static const Color textSecondaryLight = Color(0xFF525252);
  static const Color textTertiaryLight = Color(0xFF737373);
  static const Color textDisabledLight = Color(0xFFA3A3A3);

  static const Color textPrimaryDark = Color(0xFFFAFAFA);
  static const Color textSecondaryDark = Color(0xFFD4D4D4);
  static const Color textTertiaryDark = Color(0xFFA3A3A3);
  static const Color textDisabledDark = Color(0xFF525252);

  // LIGHT THEME
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: brandPrimary,
      onPrimary: onBrandPrimary,
      secondary: brandSecondary,
      onSecondary: onBrandSecondary,
      tertiary: brandTertiary,
      onTertiary: onBrandTertiary,
      error: transactionFailed,
      onError: onTransactionFailed,
      surface: surfaceLight,
      onSurface: textPrimaryLight,
      surfaceContainerHighest: surfaceContainerHighLight,
      surfaceContainer: surfaceContainerLight,
      surfaceContainerLow: surfaceContainerLowLight,
      outline: borderLight,
      outlineVariant: dividerLight,
    );

    return _buildTheme(colorScheme, false);
  }

  // DARK THEME
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: brandPrimary,
      onPrimary: onBrandPrimary,
      secondary: brandSecondary,
      onSecondary: onBrandSecondary,
      tertiary: brandTertiary,
      onTertiary: onBrandTertiary,
      error: transactionFailed,
      onError: onTransactionFailed,
      surface: surfaceDark,
      onSurface: textPrimaryDark,
      surfaceContainerHighest: surfaceContainerHighDark,
      surfaceContainer: surfaceContainerDark,
      surfaceContainerLow: surfaceContainerLowDark,
      outline: borderDark,
      outlineVariant: dividerDark,
    );

    return _buildTheme(colorScheme, true);
  }

  // CONSTRUCTOR DE TEMA
  static ThemeData _buildTheme(ColorScheme colorScheme, bool isDark) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,

      // Typography
      textTheme: _textTheme(isDark),

      // AppBar - Header del POS
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surface,

        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
      ),

      // Buttons - Acciones principales del POS
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: AppTheme.brandPrimary,
          foregroundColor: AppTheme.onBrandPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.outline, width: 1.5),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Cards - Productos, tickets, resúmenes
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // Input - Búsqueda de productos, cantidades, códigos
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
      ),

      // List Tiles - Items del carrito, historial de ventas
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Dialogs - Confirmaciones, alertas
      dialogTheme: DialogThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: colorScheme.surfaceContainer,
      ),

      // Bottom Sheets - Métodos de pago, opciones extras
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: colorScheme.surfaceContainer,
      ),

      // Dividers
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: colorScheme.outlineVariant,
      ),

      // Chips - Filtros, categorías
      chipTheme: ChipThemeData(
        labelStyle: GoogleFonts.inter(
          color: colorScheme.onPrimaryContainer,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      // Switches - Filtros, categorías
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outlineVariant;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return colorScheme.outline;
        }),
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.pressed)) {
            return colorScheme.primary.withValues(alpha: 0.2);
          }
          return null;
        }),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),

      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        color: colorScheme.surfaceContainer,
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        position: PopupMenuPosition.under,
      ),
    );
  }

  // TYPOGRAPHY
  static TextTheme _textTheme(bool isDark) {
    final baseColor = isDark ? textPrimaryDark : textPrimaryLight;
    final secondaryColor = isDark ? textSecondaryDark : textSecondaryLight;

    return TextTheme(
      // Displays - Totales grandes, números principales
      displayLarge: GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        color: baseColor,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: baseColor,
        height: 1.15,
      ),

      // Headlines - Títulos de secciones, headers
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: baseColor,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: baseColor,
        height: 1.3,
      ),

      // Titles - Nombres de productos, clientes
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: baseColor,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: baseColor,
        height: 1.5,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: baseColor,
        height: 1.4,
      ),

      // Body - Descripciones, detalles
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: baseColor,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: baseColor,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: secondaryColor,
        height: 1.3,
      ),

      // Labels - Botones, badges, etiquetas
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: baseColor,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: baseColor,
        height: 1.3,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: secondaryColor,
        height: 1.4,
      ),
    );
  }
}

// Theme Provider
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void setLight() => state = ThemeMode.light;
  void setDark() => state = ThemeMode.dark;
  void setSystem() => state = ThemeMode.system;

  bool get isLight => state == ThemeMode.light;
  bool get isDark => state == ThemeMode.dark;
  bool get isSystem => state == ThemeMode.system;
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

// Extensions para acceso rápido en el código
extension AppColorExtension on BuildContext {
  // Transacciones
  Color get addToCart => AppTheme.actionAddToCart;
  Color get paymentSuccess => AppTheme.transactionSuccess;
  Color get paymentPending => AppTheme.transactionPending;
  Color get paymentFailed => AppTheme.transactionFailed;
  Color get refund => AppTheme.transactionRefund;

  // Productos
  Color get inStock => AppTheme.productInStock;
  Color get lowStock => AppTheme.productLowStock;
  Color get outOfStock => AppTheme.productOutOfStock;
  Color get premium => AppTheme.productPremium;
  Color get onSale => AppTheme.productOnSale;
  Color get newProduct => AppTheme.productNew;

  // Clientes
  Color get vipCustomer => AppTheme.customerVIP;
  Color get loyalCustomer => AppTheme.customerLoyal;
  Color get newCustomer => AppTheme.customerNew;
  Color get creditCustomer => AppTheme.customerWithCredit;
  Color get delinquentCustomer => AppTheme.customerDelinquent;

  // Métodos de pago
  Color get cashPayment => AppTheme.paymentCash;
  Color get cardPayment => AppTheme.paymentCard;
  Color get transferPayment => AppTheme.paymentTransfer;
  Color get walletPayment => AppTheme.paymentDigitalWallet;
  Color get creditPayment => AppTheme.paymentStoreCredit;

  // Métricas
  Color get salesMetric => AppTheme.metricDailySales;
  Color get expensesMetric => AppTheme.metricExpenses;
  Color get profitMetric => AppTheme.metricProfit;
  Color get cashFlowMetric => AppTheme.metricCashFlow;
  Color get targetMetric => AppTheme.metricTarget;
}
