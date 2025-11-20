# Implementación de Impuestos en POS - Resumen Técnico

## 📋 Estructura de Datos

### Tablas Involucradas

1. **`tax_rates`**: Catálogo de tasas de impuesto
   - `rate`: Tasa decimal (ej: 0.16 para IVA 16%)
   - Tasas predefinidas: IVA_16 (0.16), EXENTO (0.0), IEPS_8 (0.08)

2. **`product_taxes`**: Relación Producto-Impuesto
   - Conecta productos con sus impuestos aplicables
   - `apply_order`: Orden de aplicación para impuestos compuestos

3. **`sale_items`**: Detalle de venta
   - `unit_price_cents`: Precio base unitario (neto, sin impuestos)
   - `subtotal_cents`: Precio neto total (precio × cantidad)
   - `tax_cents`: Total de impuestos aplicados
   - `total_cents`: Precio bruto (subtotal + impuestos)

4. **`sale_item_taxes`**: Snapshot de impuestos aplicados
   - Captura histórica de cada impuesto al momento de la venta
   - `tax_name`, `tax_rate`, `tax_amount_cents`

## 🔢 Proceso de Cálculo

### Fase 1: Configuración (Antes de la venta)
- Los productos tienen impuestos asignados en `product_taxes`
- Nuevos productos reciben automáticamente el impuesto por defecto (IVA_16)

### Fase 2: Cálculo en Transacción (Al agregar al carrito)

**Fórmulas aplicadas:**

1. **Precio Base (Neto)**:
   ```
   P_neto = unit_price_cents × quantity
   ```

2. **Cálculo de cada Impuesto**:
   ```
   I_i = P_neto × R_i
   ```
   Donde `R_i` es la tasa decimal del impuesto (ej: 0.16)

3. **Total de Impuestos**:
   ```
   I_total = Σ I_i
   ```

4. **Precio Total (Bruto)**:
   ```
   P_bruto = P_neto + I_total
   ```

**Implementación en código** (`pos_providers.dart`):
```dart
// 1. Precio base
final subtotalCents = (unitPriceCents * quantity).round();

// 2. Calcular cada impuesto
for (final tax in productTaxes) {
  final taxAmount = (subtotalCents * tax.rate).round();
  taxCents += taxAmount;
  taxes.add(SaleItemTax(...));
}

// 3. Precio total
final totalCents = subtotalCents + taxCents;
```

### Fase 3: Persistencia (Al completar venta)

**En `SaleRepositoryImpl.createSale`:**

1. Inserta la venta en `sales` con totales agregados
2. Inserta cada item en `sale_items` con sus totales
3. **Crucial**: Inserta cada impuesto en `sale_item_taxes` como snapshot histórico

```dart
// Para cada item
for (final item in sale.items) {
  // Insertar item
  await txn.insert(tableSaleItems, itemModel.toMap());
  
  // Insertar snapshot de impuestos
  for (final tax in item.taxes) {
    await txn.insert(tableSaleItemTaxes, {
      'sale_item_id': itemId,
      'tax_rate_id': tax.taxRateId,
      'tax_name': tax.taxName,
      'tax_rate': tax.taxRate,
      'tax_amount_cents': tax.taxAmountCents,
    });
  }
}
```

## 🎯 Visualización en UI

### 1. CartSection (Carrito)
- Muestra impuesto por item: `+ Imp: $X.XX`
- Total incluye impuestos

### 2. PaymentDialog (Pago)
- Desglose:
  - Subtotal (neto)
  - Impuestos
  - Total (bruto)

### 3. SaleDetailPage (Detalle de Venta)
- Por cada producto:
  - Cantidad × Precio = Subtotal
  - Desglose de impuestos aplicados:
    - Nombre del impuesto
    - Tasa (%)
    - Monto
  - Total del item

## ✅ Ventajas del Diseño

1. **Inmutabilidad**: Los cambios futuros en tasas no afectan ventas históricas
2. **Auditoría**: Cada impuesto aplicado queda registrado con su tasa exacta
3. **Flexibilidad**: Soporte para múltiples impuestos por producto
4. **Precisión**: Cálculos en centavos evitan errores de redondeo

## 📝 Asignación de Impuestos

### Productos Nuevos ✅
Los productos creados a través de la aplicación reciben **automáticamente** el impuesto por defecto (IVA_16) al momento de su creación.

**Implementación:** `lib/data/repositories/product_repository_impl.dart`
```dart
Future<int> createProduct(Product product) async {
  // 1. Inserta el producto
  final productId = await db.insert(tableProducts, ...);
  
  // 2. Busca el impuesto por defecto (is_default = 1)
  final defaultTax = await db.query(
    tableTaxRates,
    where: 'is_default = ? AND is_active = ?',
    whereArgs: [1, 1],
  );
  
  // 3. Asigna automáticamente el impuesto al producto
  if (defaultTax.isNotEmpty) {
    await db.insert(tableProductTaxes, {
      'product_id': productId,
      'tax_rate_id': defaultTax.first['id'],
      'apply_order': 1,
    });
  }
  
  return productId;
}
```

### Productos Existentes
Los productos creados **antes** de implementar esta funcionalidad pueden no tener impuestos asignados.

**Solución:** Toda la lógica está dentro de la aplicación Flutter. Los productos nuevos se crean automáticamente con impuestos. Para productos existentes sin impuestos, se pueden editar desde la UI de productos.

## 📝 Notas Importantes

- **`sale_price_cents`** en `products` es el **precio base (neto, sin impuestos)**
- **`tax.rate`** en `tax_rates` es **decimal** (0.16), NO porcentaje (16.0)
- Los nuevos productos reciben automáticamente el impuesto por defecto
- **Toda la lógica está implementada en la aplicación**
