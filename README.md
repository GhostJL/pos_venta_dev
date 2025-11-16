# Aplicación Móvil de Punto de Venta (PDV)

Esta es una aplicación móvil basada en Flutter diseñada para gestionar operaciones de punto de venta, incluyendo sesiones de caja y movimientos de efectivo. Cuenta con una interfaz de usuario limpia y moderna y utiliza Firebase para los servicios de backend.

## ✨ Características

- **Autenticación**: Inicio de sesión seguro y creación de cuentas de usuario.
- **Sesiones de Caja**: Inicia, gestiona y cierra sesiones de caja con un saldo inicial.
- **Movimientos de Efectivo**: Registra transacciones de entrada y salida de efectivo con detalles como monto, motivo y descripción.
- **Panel de Control**: Un centro principal que muestra métricas clave como los ingresos del día, el estado de la sesión y el total de movimientos.
- **Interfaz de Usuario Moderna**: Un sistema de diseño visualmente atractivo y coherente con un tema y tipografía personalizados.
- **Diseño Adaptable**: Se adapta a varios tamaños de pantalla para una experiencia fluida en dispositivos móviles y web.
- **Gestión de Estado**: Construido con `flutter_riverpod` para una gestión de estado escalable y mantenible.
- **Navegación**: Utiliza `go_router` para una solución de enrutamiento declarativa y robusta.

## 🚀 Tecnologías Utilizadas

- **Frontend**: Flutter
- **Backend**: Firebase (Authentication, Firestore)
- **Gestión de Estado**: Riverpod
- **Enrutamiento**: go_router
- **Estilos**: Google Fonts

## 🏁 Cómo Empezar

Para obtener una copia local y ponerla en funcionamiento, sigue estos sencillos pasos.

### Prerrequisitos

- Flutter SDK: [Guía de Instalación](https://flutter.dev/docs/get-started/install)
- Firebase CLI: `npm install -g firebase-tools`

### Instalación

1. **Clona el repositorio**
   ```sh
   git clone https://tu-url-del-repositorio.git
   ```
2. **Instala los paquetes**
   ```sh
   flutter pub get
   ```
3. **Ejecuta la aplicación**
   ```sh
   flutter run
   ```

## 📄 Licencia

Distribuido bajo la Licencia MIT. Consulta `LICENSE` para más información.
