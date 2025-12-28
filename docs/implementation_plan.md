# Plan de Refactorización e Implementación de Arquitectura Profesional

El objetivo es elevar la calidad de la arquitectura del sistema POS, implementando manejo de errores robusto, desacoplamiento de base de datos, paginación y logging, asegurando que el sistema permanezca operativo.

## Cambios Propuestos

### 1. Infraestructura Core y Dependencias
*   **[NEW]** Agregar librerías `fpdart` (para `Either`) y `logging` (paquete oficial de dart.dev).
*   **[NEW] `lib/core/error/failures.dart`**: Definir jerarquía de fallos (`Failure`, `DatasourceFailure`, `UnexpectedFailure`).
*   **[NEW] `lib/core/error/exceptions.dart`**: Definir excepciones de infraestructura.
*   **[NEW] `lib/core/utils/logger.dart`**: Configuración básica de Logger.

### 2. Refactorización Vertical: Productos (Prueba de Concepto y Estandarización)
Este será el modelo para el resto del sistema.
*   **[NEW] `lib/data/datasources/product_local_datasource.dart`**: Interfaz abstracta para acceso a datos de productos.
*   **[NEW] `lib/data/datasources/product_local_datasource_impl.dart`**: Implementación concreta usando `DatabaseHelper` (moviendo la lógica SQL aquí).
*   **[MODIFY] `lib/domain/repositories/product_repository.dart`**:
    *   Cambiar retornos de `Future<T>` a `Future<Either<Failure, T>>`.
    *   Agregar parámetros de paginación (`page`, `limit`) a `getAllProducts`.
*   **[MODIFY] `lib/data/repositories/product_repository_impl.dart`**:
    *   Inyectar `ProductLocalDataSource` en lugar de `DatabaseHelper`.
    *   Implementar `try-catch` para capturar excepciones y retornan `Left(Failure)`.
*   **[MODIFY] Casos de Uso de Productos**:
    *   Actualizar para manejar y propagar `Either`.
*   **[MODIFY] `lib/presentation/providers/product_provider.dart`**:
    *   Actualizar `ProductList` y `ProductNotifier` para consumir `Either` (mecanismo `fold`).

### 3. Implementación de Logging y Auditoría
*   **[NEW] `lib/domain/services/audit_service.dart`**: Interfaz para registrar logs.
*   **[NEW] `lib/data/services/audit_service_impl.dart`**: Implementación que escribe en `tableAuditLogs`.

## Verification Plan

### Automated Verification
*   Ejecutar `flutter analyze` para asegurar que no hay tipos rotos tras los cambios de firma.
*   Verificar que la compilación es exitosa.

### Manual Verification
*   **Productos**: Verificar que la lista de productos carga correctamente (paginada).
*   **Errores**: Simular un fallo de base de datos (ej. renombrar tabla temporalmente en código) y verificar que la UI muestra un mensaje de error elegante en lugar de crashear.
*   **Migración**: Verificar que los datos existentes se siguen leyendo correctamente a través de la nueva capa de DataSource.
