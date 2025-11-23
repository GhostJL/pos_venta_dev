# 📚 Documentación del Proyecto POS Venta

Esta carpeta contiene la documentación técnica de implementaciones importantes del sistema.

## 📑 Índice de Documentos

### 🛠️ Implementaciones de Módulos

1. **[PURCHASE_MODULE_IMPLEMENTATION.md](./PURCHASE_MODULE_IMPLEMENTATION.md)**
   - Implementación completa del módulo de compras
   - Proceso de recepción de mercancía
   - Actualización de inventario y Kardex
   - Política de costos (LIFO)

2. **[CASH_SESSION_IMPLEMENTATION.md](./CASH_SESSION_IMPLEMENTATION.md)**
   - Sistema de apertura y cierre de caja
   - Cálculo automático de diferencias
   - Integración con auditoría
   - Guard de sesión de caja

3. **[BARCODE_SCANNER_IMPLEMENTATION.md](./BARCODE_SCANNER_IMPLEMENTATION.md)**
   - Implementación del scanner de códigos de barras
   - Integración en POS, formularios y búsquedas
   - Soporte para EAN-13, EAN-8 y Code 128
   - Componentes reutilizables

4. **[TAX_IMPLEMENTATION.md](./TAX_IMPLEMENTATION.md)**
   - Sistema de impuestos
   - Cálculo de IVA e ISR
   - Integración con productos y ventas

### 🔄 Refactorizaciones

5. **[REFACTORING_PRODUCTS_PAGE.md](./REFACTORING_PRODUCTS_PAGE.md)**
   - Refactorización de `products_page.dart`
   - Reducción de 676 a 239 líneas (64.6%)
   - Aplicación de Clean Code y Clean Architecture
   - Componentes creados y estructura final

### 📖 Guías de Desarrollo

6. **[GEMINI.md](./GEMINI.md)**
   - Guías completas de desarrollo para IA
   - Estándares de Flutter y Material Design
   - Arquitectura y patrones recomendados
   - Gestión de estado con Riverpod

## 🎯 Propósito

Estos documentos sirven como:

- ✅ **Referencia técnica** para entender implementaciones complejas
- ✅ **Guía de mantenimiento** para futuras modificaciones
- ✅ **Documentación de decisiones** arquitectónicas y de diseño
- ✅ **Base de conocimiento** para nuevos desarrolladores

## 📝 Convenciones

- Los archivos están en formato Markdown (.md)
- Incluyen ejemplos de código cuando es relevante
- Documentan tanto la implementación como el razonamiento detrás de las decisiones
- Se mantienen actualizados con cambios significativos

## 🔍 Cómo Usar Esta Documentación

1. **Para entender una funcionalidad**: Lee el documento correspondiente al módulo
2. **Para modificar código existente**: Consulta la documentación para entender el contexto
3. **Para agregar nuevas funcionalidades**: Revisa patrones similares en documentos existentes
4. **Para onboarding**: Comienza con GEMINI.md y luego revisa los módulos principales

---

**Última actualización**: 2025-11-23
