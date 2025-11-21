# Revisión del Flujo de Cajero (Cashier Flow)

**Fecha de Revisión:** 2025-11-20  
**Objetivo:** Verificar la implementación del flujo completo de cajero según las especificaciones del sistema POS.

---

## 📋 Resumen Ejecutivo

### Estado General: ⚠️ **IMPLEMENTACIÓN PARCIAL**

La aplicación cuenta con la **estructura base** para el flujo de cajero, pero **faltan componentes críticos** para completar el flujo operativo completo. A continuación se detalla el análisis por sección.

---

## 1. Apertura de Caja ❌ **NO IMPLEMENTADO**

### 📌 Especificación Requerida:
- Al iniciar sesión, el sistema debe verificar si hay un `cash_sessions` abierto para ese `user_id` y `warehouse_id`
- Si no hay sesión, se debe solicitar al cajero ingresar el `opening_balance_cents` (fondo de caja)
- Se debe crear un registro en `cash_sessions` con `status = 'open'`

### ✅ Estructura de Datos Existente:
```sql
-- Tabla cash_sessions (EXISTE)
CREATE TABLE cash_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  warehouse_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  opening_balance_cents INTEGER NOT NULL,
  closing_balance_cents INTEGER,
  expected_balance_cents INTEGER,
  difference_cents INTEGER,
  status TEXT NOT NULL DEFAULT 'open',
  opened_at TEXT NOT NULL,
  closed_at TEXT,
  notes TEXT
)
```

### ✅ Repositorio Implementado:
**Archivo:** `lib/data/repositories/cash_session_repository_impl.dart`

```dart
// MÉTODOS DISPONIBLES:
Future<CashSession> openSession(int warehouseId, int openingBalanceCents)
Future<CashSession> closeSession(int sessionId, int closingBalanceCents)
Future<CashSession?> getCurrentSession()
```

### ❌ Faltantes Críticos:

1. **No existe pantalla de apertura de caja**
   - No hay UI para solicitar el fondo inicial
   - No hay validación al iniciar sesión para verificar sesión abierta
   - No hay flujo que obligue al cajero a abrir caja antes de vender

2. **No hay integración en el login**
   - El `login_page.dart` no verifica si existe una sesión abierta
   - No redirige a apertura de caja si no hay sesión

3. **No hay use cases implementados**
   - No existe `OpenCashSessionUseCase`
   - No existe `GetCurrentCashSessionUseCase`

### 🔧 Impacto:
**CRÍTICO** - El cajero puede realizar ventas sin haber abierto caja, lo cual rompe el control de efectivo.

---

## 2. Pantalla Principal de Venta (POS) ✅ **IMPLEMENTADO**

### 📌 Especificación Requerida:

| Área | Fuente de Datos / Acción | Estado |
|------|--------------------------|--------|
| Búsqueda de Producto | Campo que busca en `products` por `code`, `barcode`, `name` | ✅ IMPLEMENTADO |
| Lista de Productos | Muestra `sale_items` con `products.name`, `quantity`, precios | ✅ IMPLEMENTADO |
| Stock en Tiempo Real | Muestra `inventory.quantity_on_hand` para `product_id` y `warehouse_id` | ✅ IMPLEMENTADO |
| Información de la Venta | Muestra `sales.subtotal_cents`, `tax_cents`, `total_cents` | ✅ IMPLEMENTADO |
| Botón 'Añadir Cliente' | Buscar/crear cliente en `customers` para `sales.customer_id` | ✅ IMPLEMENTADO |

### ✅ Archivos Implementados:

1. **`lib/presentation/pages/sales_page.dart`**
   - Layout responsivo (móvil, tablet, desktop)
   - Separación entre productos y carrito

2. **`lib/presentation/widgets/pos/product_grid_section.dart`**
   - Búsqueda de productos ✅
   - Visualización de stock en tiempo real ✅
   - Grid adaptativo según dispositivo ✅

3. **`lib/presentation/widgets/pos/cart_section.dart`**
   - Selección de cliente ✅
   - Lista de items del carrito ✅
   - Cálculo de subtotal, impuestos y total ✅
   - Controles de cantidad ✅

### 🎯 Funcionalidad Verificada:

```dart
// BÚSQUEDA DE PRODUCTOS
TextField(
  onChanged: (value) {
    ref.read(productListProvider.notifier).searchProducts(value);
  }
)

// STOCK EN TIEMPO REAL
Text('Stock: ${product.stock?.toStringAsFixed(0) ?? '0'}')

// SELECCIÓN DE CLIENTE
InkWell(
  onTap: () {
    showDialog(context: context, builder: (context) => CustomerSelectionDialog());
  }
)

// TOTALES CALCULADOS
double get subtotal => cart.fold(0.0, (sum, item) => sum + (item.subtotalCents / 100));
double get tax => cart.fold(0.0, (sum, item) => sum + (item.taxCents / 100));
double get total => cart.fold(0.0, (sum, item) => sum + (item.totalCents / 100));
```

---

## 3. Proceso de Pago ⚠️ **PARCIALMENTE IMPLEMENTADO**

### 📌 Especificación Requerida:

| Paso | Acción | Estado |
|------|--------|--------|
| 1. Inicio de Pago | Cajero presiona "Pagar" | ✅ IMPLEMENTADO |
| 2. Creación de Encabezado | Registra venta en `sales` con `status = 'completed'` | ✅ IMPLEMENTADO |
| 3. Registro de Ítems | Cada producto en `sale_items` con precios y cantidad | ✅ IMPLEMENTADO |
| 4. Registro de Impuestos | Detalle en `sale_item_taxes` usando `tax_rates` | ✅ IMPLEMENTADO |
| 5. Registro de Pago | Crea registro en `sale_payments` | ✅ IMPLEMENTADO |
| 6. Afectación de Inventario | Crea `inventory_movements` tipo 'sale' y actualiza `inventory` | ⚠️ PARCIAL |

### ✅ Implementación Actual:

**Archivo:** `lib/data/repositories/sale_repository_impl.dart`

```dart
Future<int> createSale(Sale sale) async {
  return await db.transaction((txn) async {
    // 1. Insert Sale ✅
    final saleId = await txn.insert(DatabaseHelper.tableSales, saleModel.toMap());
    
    // 2. Insert Items ✅
    for (final item in sale.items) {
      final saleItemId = await txn.insert(DatabaseHelper.tableSaleItems, itemMap);
      
      // 3. Insert Item Taxes ✅
      for (final tax in item.taxes) {
        await txn.insert(DatabaseHelper.tableSaleItemTaxes, taxMap);
      }
      
      // 4. Update Inventory ✅
      await txn.rawUpdate('''
        UPDATE ${DatabaseHelper.tableInventory}
        SET quantity_on_hand = quantity_on_hand - ?
        WHERE product_id = ? AND warehouse_id = ?
      ''', [item.quantity, item.productId, sale.warehouseId]);
      
      // ❌ FALTA: No se registra en inventory_movements (Kardex)
    }
    
    // 5. Insert Payments ✅
    for (final payment in sale.payments) {
      await txn.insert(DatabaseHelper.tableSalePayments, paymentMap);
    }
  });
}
```

### ❌ Faltantes Identificados:

1. **No se registran movimientos de inventario (Kardex)**
   - La venta actualiza `inventory.quantity_on_hand` ✅
   - **PERO** no crea registros en `inventory_movements` ❌
   - No hay trazabilidad de las salidas de inventario

2. **No se vincula con cash_sessions**
   - Los pagos en efectivo no se relacionan con la sesión de caja abierta
   - No se actualiza el `expected_balance_cents` de la sesión

### 🔧 Código Faltante:

```dart
// DEBE AGREGARSE en createSale():
for (final item in sale.items) {
  // ... código existente ...
  
  // REGISTRAR MOVIMIENTO DE INVENTARIO (KARDEX)
  final inventoryBefore = await txn.rawQuery('''
    SELECT quantity_on_hand FROM ${DatabaseHelper.tableInventory}
    WHERE product_id = ? AND warehouse_id = ?
  ''', [item.productId, sale.warehouseId]);
  
  final qtyBefore = inventoryBefore.first['quantity_on_hand'] as double;
  final qtyAfter = qtyBefore - item.quantity;
  
  await txn.insert(DatabaseHelper.tableInventoryMovements, {
    'product_id': item.productId,
    'warehouse_id': sale.warehouseId,
    'movement_type': 'sale',
    'quantity': -item.quantity,
    'quantity_before': qtyBefore,
    'quantity_after': qtyAfter,
    'reference_type': 'sale',
    'reference_id': saleId,
    'performed_by': sale.cashierId,
    'movement_date': sale.saleDate.toIso8601String(),
  });
}
```

---

## 4. Cierre de Caja ❌ **NO IMPLEMENTADO**

### 📌 Especificación Requerida:
- Cajero selecciona "Cerrar Caja" o "Cerrar Turno"
- Sistema suma todos los `sale_payments` de tipo 'cash' de la sesión
- Sistema suma `cash_movements` (entradas/salidas) de la sesión
- Calcula `expected_balance_cents`
- Cajero ingresa `closing_balance_cents` (conteo físico)
- Se actualiza `cash_sessions` con montos de cierre, `difference_cents` y `status = 'closed'`
- Se registra evento en `audit_logs`

### ✅ Estructura de Datos Existente:
```sql
-- Tabla cash_movements (EXISTE)
CREATE TABLE cash_movements (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  cash_session_id INTEGER NOT NULL,
  movement_type TEXT NOT NULL,
  amount_cents INTEGER NOT NULL,
  reason TEXT NOT NULL,
  description TEXT,
  performed_by INTEGER NOT NULL,
  movement_date TEXT NOT NULL
)
```

### ✅ Repositorio Implementado:
**Archivo:** `lib/data/repositories/cash_session_repository_impl.dart`

```dart
Future<CashSession> closeSession(int sessionId, int closingBalanceCents) async {
  await db.update('cash_sessions', {
    'closing_balance_cents': closingBalanceCents,
    'status': 'closed',
    'closed_at': now.toIso8601String(),
  }, where: 'id = ? AND user_id = ?', whereArgs: [sessionId, _userId]);
}
```

### ❌ Faltantes Críticos:

1. **No existe pantalla de cierre de caja**
   - No hay UI para ingresar el conteo físico
   - No hay cálculo automático del efectivo esperado
   - No hay visualización de la diferencia

2. **No se calcula el expected_balance_cents**
   - El método `closeSession()` solo guarda el `closing_balance_cents`
   - No suma los pagos en efectivo de la sesión
   - No suma los `cash_movements`

3. **No hay integración con sale_payments**
   - Los pagos en efectivo no se vinculan a `cash_session_id`
   - No se puede calcular el efectivo esperado

4. **No se registra en audit_logs**
   - No hay auditoría del cierre de caja

### 🔧 Lógica Faltante:

```dart
// DEBE IMPLEMENTARSE:
Future<CashSession> closeSession(int sessionId, int closingBalanceCents) async {
  final db = await _databaseHelper.database;
  
  return await db.transaction((txn) async {
    // 1. Obtener sesión actual
    final session = await getCurrentSession();
    
    // 2. Calcular efectivo esperado
    // 2a. Sumar pagos en efectivo de ventas
    final cashSales = await txn.rawQuery('''
      SELECT COALESCE(SUM(amount_cents), 0) as total
      FROM sale_payments sp
      INNER JOIN sales s ON sp.sale_id = s.id
      INNER JOIN cash_sessions cs ON s.cashier_id = cs.user_id
      WHERE cs.id = ? AND sp.payment_method = 'Efectivo'
      AND s.sale_date >= cs.opened_at
    ''', [sessionId]);
    
    // 2b. Sumar movimientos de efectivo
    final cashMovements = await txn.rawQuery('''
      SELECT COALESCE(SUM(amount_cents), 0) as total
      FROM cash_movements
      WHERE cash_session_id = ?
    ''', [sessionId]);
    
    final expectedBalanceCents = session.openingBalanceCents + 
                                 (cashSales.first['total'] as int) +
                                 (cashMovements.first['total'] as int);
    
    final differenceCents = closingBalanceCents - expectedBalanceCents;
    
    // 3. Actualizar sesión
    await txn.update('cash_sessions', {
      'closing_balance_cents': closingBalanceCents,
      'expected_balance_cents': expectedBalanceCents,
      'difference_cents': differenceCents,
      'status': 'closed',
      'closed_at': DateTime.now().toIso8601String(),
    }, where: 'id = ?', whereArgs: [sessionId]);
    
    // 4. Registrar en audit_logs
    await txn.insert('audit_logs', {
      'table_name': 'cash_sessions',
      'record_id': sessionId,
      'action': 'close_session',
      'user_id': session.userId,
      'username': 'username', // obtener del usuario
      'new_values': json.encode({
        'closing_balance_cents': closingBalanceCents,
        'expected_balance_cents': expectedBalanceCents,
        'difference_cents': differenceCents,
      }),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    return await getCurrentSession(); // retornar sesión actualizada
  });
}
```

---

## 5. Integración Principal: Apertura y Cierre de Caja ❌ **NO IMPLEMENTADO**

### Estado Actual:
- ✅ Tablas de base de datos creadas (`cash_sessions`, `cash_movements`)
- ✅ Repositorios básicos implementados
- ❌ **No hay UI para apertura de caja**
- ❌ **No hay UI para cierre de caja**
- ❌ **No hay validación en login**
- ❌ **No hay use cases**
- ❌ **No hay providers de Riverpod**
- ❌ **No se vinculan ventas con sesiones de caja**

---

## 📊 Tabla Resumen de Implementación

| Componente | Especificación | Implementado | Faltante | Prioridad |
|------------|----------------|--------------|----------|-----------|
| **Apertura de Caja** | | | | |
| - Tabla `cash_sessions` | ✅ | ✅ | - | - |
| - Repository | ✅ | ✅ | - | - |
| - Use Cases | ✅ | ❌ | Crear use cases | 🔴 ALTA |
| - UI Apertura | ✅ | ❌ | Pantalla completa | 🔴 ALTA |
| - Validación en Login | ✅ | ❌ | Verificar sesión | 🔴 ALTA |
| **Pantalla POS** | | | | |
| - Búsqueda de productos | ✅ | ✅ | - | - |
| - Lista de items | ✅ | ✅ | - | - |
| - Stock en tiempo real | ✅ | ✅ | - | - |
| - Totales | ✅ | ✅ | - | - |
| - Selección de cliente | ✅ | ✅ | - | - |
| **Proceso de Pago** | | | | |
| - Creación de venta | ✅ | ✅ | - | - |
| - Registro de items | ✅ | ✅ | - | - |
| - Registro de impuestos | ✅ | ✅ | - | - |
| - Registro de pagos | ✅ | ✅ | - | - |
| - Actualización inventario | ✅ | ✅ | - | - |
| - Registro Kardex | ✅ | ❌ | Crear movements | 🟡 MEDIA |
| - Vincular con sesión | ✅ | ❌ | Relacionar pagos | 🟡 MEDIA |
| **Cierre de Caja** | | | | |
| - Tabla `cash_movements` | ✅ | ✅ | - | - |
| - Repository | ✅ | ✅ (básico) | Lógica completa | 🔴 ALTA |
| - Use Cases | ✅ | ❌ | Crear use cases | 🔴 ALTA |
| - UI Cierre | ✅ | ❌ | Pantalla completa | 🔴 ALTA |
| - Cálculo automático | ✅ | ❌ | Implementar | 🔴 ALTA |
| - Auditoría | ✅ | ❌ | Registrar en logs | 🟡 MEDIA |

---

## 🎯 Recomendaciones de Implementación

### Prioridad 1 - CRÍTICO (Implementar Inmediatamente)

1. **Apertura de Caja**
   - Crear `OpenCashSessionUseCase`
   - Crear `GetCurrentCashSessionUseCase`
   - Crear `CashSessionProvider` con Riverpod
   - Crear `CashSessionOpenPage` (UI)
   - Modificar `LoginPage` para verificar sesión abierta

2. **Cierre de Caja**
   - Completar lógica de `closeSession()` en repository
   - Crear `CloseCashSessionUseCase`
   - Crear `CashSessionClosePage` (UI)
   - Implementar cálculo de efectivo esperado
   - Agregar registro en `audit_logs`

### Prioridad 2 - IMPORTANTE (Implementar Pronto)

3. **Vincular Ventas con Sesiones**
   - Agregar `cash_session_id` a tabla `sales` (migración)
   - Modificar `createSale()` para vincular con sesión activa
   - Permitir filtrar ventas por sesión de caja

4. **Registro de Movimientos de Inventario (Kardex)**
   - Modificar `createSale()` para registrar en `inventory_movements`
   - Crear vista de Kardex por producto
   - Implementar trazabilidad completa

### Prioridad 3 - MEJORAS (Implementar Después)

5. **Movimientos de Efectivo**
   - Crear UI para registrar entradas/salidas de efectivo
   - Implementar `CreateCashMovementUseCase`
   - Agregar validaciones y permisos

6. **Reportes de Caja**
   - Reporte de sesión de caja (detalle)
   - Historial de sesiones
   - Análisis de diferencias

---

## 🔍 Conclusión

La aplicación tiene una **base sólida** con:
- ✅ Estructura de base de datos completa
- ✅ Repositorios básicos implementados
- ✅ Pantalla POS funcional
- ✅ Proceso de venta operativo

**PERO** le faltan componentes **CRÍTICOS** para el flujo completo de cajero:
- ❌ No hay apertura de caja
- ❌ No hay cierre de caja
- ❌ No hay validación de sesión activa
- ❌ No hay trazabilidad completa (Kardex)

**Riesgo Operativo:** Un cajero puede realizar ventas sin haber abierto caja, lo que impide el control de efectivo y la conciliación al final del turno.

**Acción Recomendada:** Implementar **Prioridad 1** antes de poner el sistema en producción.
