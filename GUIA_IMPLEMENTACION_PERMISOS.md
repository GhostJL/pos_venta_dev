# Guía Completa de Implementación de Permisos - Páginas Restantes

## ✅ COMPLETADO

1. **Widget Reutilizable**: `lib/presentation/widgets/permission_denied_widget.dart` ✅
2. **Cash Session Open Page**: Usa PermissionDeniedWidget ✅  
3. **Cash Session Close Page**: Pendiente de actualizar

---

## 📋 PATRÓN PARA PÁGINAS CON CustomDataTable

### Archivos que necesitan este patrón:

**Catálogo** (CATALOG_MANAGE):
- [ ] lib/presentation/pages/brands_page.dart
- [ ] lib/presentation/pages/suppliers_page.dart
- [ ] lib/presentation/pages/warehouses_page.dart
- [ ] lib/presentation/pages/tax_rates_page.dart
- [ ] lib/presentation/pages/purchases_page.dart

**Clientes** (CUSTOMER_MANAGE):
- [ ] lib/presentation/pages/customers_page.dart

---

## 🔧 PASO A PASO PARA CADA ARCHIVO

### Paso 1: Agregar imports (después de los imports existentes)

```dart
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
```

### Paso 2: En el método `build`, agregar verificación de permiso

Busca la línea donde se define el `build` method y agrega la verificación:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final [existingProvider] = ref.watch([existingProviderName]);
  
  // AGREGAR ESTA LÍNEA:
  final hasManagePermission = ref.watch(hasPermissionProvider(PermissionConstants.catalogManage));
  // Para customers_page.dart usar: PermissionConstants.customerManage
```

### Paso 3: Condicionar botones de acción

Busca donde están los `IconButton` de editar/eliminar (generalmente en un `DataCell` con un `Row`):

**ANTES:**
```dart
DataCell(
  Row(
    children: [
      IconButton(
        icon: const Icon(Icons.edit_rounded),
        onPressed: () => navigateToForm(item),
      ),
      IconButton(
        icon: const Icon(Icons.delete_rounded),
        onPressed: () => confirmDelete(context, ref, item),
      ),
    ],
  ),
),
```

**DESPUÉS:**
```dart
DataCell(
  Row(
    children: [
      if (hasManagePermission)
        IconButton(
          icon: const Icon(Icons.edit_rounded),
          onPressed: () => navigateToForm(item),
        ),
      if (hasManagePermission)
        IconButton(
          icon: const Icon(Icons.delete_rounded),
          onPressed: () => confirmDelete(context, ref, item),
        ),
    ],
  ),
),
```

### Paso 4: Condicionar botón de agregar

Busca `onAddItem` en `CustomDataTable`:

**ANTES:**
```dart
onAddItem: () => navigateToForm(),
```

**DESPUÉS:**
```dart
onAddItem: hasManagePermission ? () => navigateToForm() : () {},
```

---

## 📋 PATRÓN PARA PÁGINAS DE SOLO LECTURA

### Archivos que necesitan este patrón:

**Reportes** (REPORTS_VIEW):
- [ ] lib/presentation/pages/sales_history_page.dart

---

## 🔧 PASO A PASO PARA sales_history_page.dart

### Paso 1: Agregar imports

```dart
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/permission_denied_widget.dart';
```

### Paso 2: Agregar verificación al inicio del build

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final hasViewPermission = ref.watch(hasPermissionProvider(PermissionConstants.reportsView));
  
  if (!hasViewPermission) {
    return PermissionDeniedWidget(
      message: 'No tienes permiso para ver el historial de ventas.\n\nContacta a un administrador para obtener acceso.',
      icon: Icons.assessment_outlined,
      backRoute: '/home',
    );
  }
  
  // ... resto del código existente
}
```

---

## 📋 ACTUALIZAR cash_session_close_page.dart

### Paso 1: Agregar import del widget

Después de la línea 5 (`import 'package:posventa/presentation/providers/auth_provider.dart';`), agregar:

```dart
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/permission_denied_widget.dart';
```

### Paso 2: Buscar la sección de verificación de permiso

Busca alrededor de la línea 220 donde dice:

```dart
if (!hasClosePermission) {
  return const Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No tienes permiso para cerrar caja',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}
```

### Paso 3: Reemplazar con PermissionDeniedWidget

```dart
if (!hasClosePermission) {
  return PermissionDeniedWidget(
    message: 'No tienes permiso para cerrar sesiones de caja.\n\nContacta a un administrador para obtener acceso.',
    icon: Icons.point_of_sale_outlined,
    backRoute: '/home',
  );
}
```

---

## 🎯 EJEMPLO COMPLETO: brands_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/app/theme.dart';
import 'package:posventa/domain/entities/brand.dart';
import 'package:posventa/presentation/widgets/brand_form.dart';
import 'package:posventa/presentation/providers/brand_providers.dart';
import 'package:posventa/presentation/widgets/custom_data_table.dart';
import 'package:posventa/core/constants/permission_constants.dart';  // ← AGREGAR
import 'package:posventa/presentation/providers/permission_provider.dart';  // ← AGREGAR

class BrandsPage extends ConsumerWidget {
  const BrandsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandList = ref.watch(brandListProvider);
    final hasManagePermission = ref.watch(hasPermissionProvider(PermissionConstants.catalogManage));  // ← AGREGAR

    void navigateToForm([Brand? brand]) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BrandForm(brand: brand)),
      );
    }

    void confirmDelete(BuildContext context, WidgetRef ref, Brand brand) {
      // ... código de confirmación ...
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: brandList.when(
        data: (brands) => CustomDataTable<Brand>(
          columns: const [
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('Código')),
            DataColumn(label: Text('Estado')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: brands.map((brand) {
            return DataRow(
              cells: [
                DataCell(Text(brand.name, style: /* ... */)),
                DataCell(Text(brand.code, style: /* ... */)),
                DataCell(_buildStatusChip(brand.isActive)),
                DataCell(
                  Row(
                    children: [
                      if (hasManagePermission)  // ← AGREGAR
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: AppTheme.primary, size: 20),
                          tooltip: 'Editar Marca',
                          onPressed: () => navigateToForm(brand),
                        ),
                      if (hasManagePermission)  // ← AGREGAR
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, color: AppTheme.error, size: 20),
                          tooltip: 'Eliminar Marca',
                          onPressed: () => confirmDelete(context, ref, brand),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
          itemCount: brands.length,
          onAddItem: hasManagePermission ? () => navigateToForm() : () {},  // ← MODIFICAR
          emptyText: 'No se encontraron marcas. ¡Añade una para empezar!',
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    // ... código del chip ...
  }
}
```

---

## ✅ CHECKLIST DE VERIFICACIÓN

Después de modificar cada archivo, verifica:

- [ ] Los imports están agregados correctamente
- [ ] La variable `hasManagePermission` está declarada en el `build`
- [ ] Los botones de editar/eliminar están envueltos con `if (hasManagePermission)`
- [ ] El `onAddItem` usa el operador ternario con función vacía
- [ ] No hay errores de compilación (`flutter analyze`)
- [ ] El archivo se guarda correctamente

---

## 🧪 PRUEBAS RECOMENDADAS

### 1. Como Administrador
- Debe ver todos los botones (agregar, editar, eliminar)
- Todas las páginas deben ser accesibles

### 2. Como Cajero sin permisos
- No debe ver botones de agregar/editar/eliminar
- El botón "+" en CustomDataTable no debe hacer nada al hacer clic
- No debe poder acceder a sales_history_page

### 3. Como Cajero con CATALOG_MANAGE
- Debe ver botones en páginas de catálogo
- No debe ver botones en customers_page (si no tiene CUSTOMER_MANAGE)

---

## 📊 PROGRESO

```
Total de archivos: 8
Completados: 1 (permission_denied_widget.dart)
Pendientes: 7

Catálogo:  ░░░░░ 0/5
Clientes:  ░░░░░ 0/1  
Reportes:  ░░░░░ 0/1
```

---

## 💡 TIPS

1. **Copia exacta**: Copia el patrón exactamente como se muestra
2. **Nombres de variables**: Asegúrate de usar los nombres correctos de providers
3. **Permiso correcto**: `catalogManage` para catálogo, `customerManage` para clientes
4. **Función vacía**: Usa `() {}` no `null` para `onAddItem`
5. **Guarda frecuentemente**: Guarda después de cada cambio para evitar perder trabajo

---

## 🚀 RESULTADO ESPERADO

Al completar todos los archivos:
- ✅ Sistema de permisos 100% funcional
- ✅ UX consistente con navegación de retorno
- ✅ UI adaptativa según permisos del usuario
- ✅ Sin errores de compilación
- ✅ Experiencia fluida para todos los roles
