# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto se adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.2] - 2026-02-14

### Añadido
- **Buscar Actualizaciones**: Se agregó un ítem "Buscar Actualizaciones..." en el menú de macOS para facilitar el acceso.
- **Ventana de Actualización Dedicada**: Las actualizaciones ahora se gestionan en una ventana independiente, siempre visible.
- **Ajustes del Gesto de Agitar**: Nuevo panel de configuración para activar/desactivar y ajustar los parámetros del gesto de sacudir (`reversalTimeout` y `requiredReversals`).
- **Límite de Ventanas de Agite**: Implementado un límite máximo de ventanas flotantes simultáneas para garantizar la estabilidad del sistema.

### Mejorado
- **Experiencia de Usuario**: La ventana de actualización presenta un diseño enfocado, sin distracciones y con botones de acción claros.
- **Pruebas**: Implementada una suite completa de pruebas de widgets para la pantalla de actualización.
- **Gestión de Permisos**: La aplicación ahora refresca los permisos de agitación automáticamente al retomar el foco.
- **Lógica Nativa**: Migración de la gestión de plugins de macOS a un Swift Package moderno generado por Flutter.

### Corregido
- **Accesibilidad en Tema Oscuro**: Corregido un problema donde el texto del nombre del archivo era difícil de leer en modo oscuro.

## [1.1.1] - 2026-01-06

### Añadido
- **Integración con Homebrew**: Los usuarios ahora pueden instalar Easier Drop vía Homebrew (`brew install --cask easier-drop`).
- **Automatización de Lanzamientos**: El script `release.sh` ahora actualiza automáticamente el Cask de Homebrew y las versiones del sitio web.

### Optimización
- **División de Binarios**: Implementados builds separados para Apple Silicon (arm64) e Intel (x64), reduciendo el tamaño de la app en un ~45%.
- **Reducción de Tamaño**: Activada la ofuscación de código y eliminación de símbolos de depuración.

## [1.1.0] - 2025-12-31

### Añadido
- **Soporte Multiventana**: ¡Ahora con soporte para múltiples ventanas! Agite el ratón mientras arrastra archivos para crear una nueva ventana de EasierDrop en la posición del cursor.
- **Detección Nativa de Agitado**: Añadida detección nativa del gesto de sacudir en macOS.
- **Feedback Visual**: Estados de procesamiento en tiempo real con efectos shimmer y animaciones de éxito.
- **Analíticas y Telemetría**: Integración con Aptabase para insights de uso anónimos y seguimiento de errores.
- **Configuración de Entorno**: Soporte para archivos `.env` procesados en tiempo de compilación usando `--dart-define`.
- **Gestión de Bandeja (Tray)**: Introducido `TrayService` para interacciones más fiables con el icono del sistema.
- **Interfaz Multiventana Minimalista**: Las ventanas secundarias ahora tienen una interfaz más limpia, sin barras de título.
- **Integración con el Portapapeles**: Soporte para pegar archivos directamente usando `Cmd + V`.
- **Ventana de Configuración**: Ventana de preferencias dedicada con diseño "Liquid Glass".
- **Gestión de Ventanas**:
    - **Control de Opacidad**: Ajuste la opacidad de la ventana en tiempo real.
    - **Siempre al Frente**: Opción para mantener la zona de drop por encima de otras ventanas.
- **Localización**: Interfaz de configuración totalmente localizada (Inglés, Portugués, Español).

### Mejorado
- **Arquitectura**: Migración al patrón Repository con `FileRepository`.
- **Rendimiento**: Optimización en la adición de archivos y reducción de reconstrucciones de widgets.
- **Suite de Pruebas**: Reemplazo de pruebas obsoletas por una nueva suite integral (>85% de cobertura).

### Ajustes
- **Sensibilidad del Gesto de Agitado**: Reducido el umbral necesario para facilitar el accionamiento del gesto.

### Corregido
- **Estabilidad de la IU**: Resuelto error de `ScrollController` reemplazando `text_marquee` por `marquee_text`.

## [1.0.4] - 2025-12-28

### Corregido
- **Comportamiento al Cerrar Ventana**: Corregido el error donde cerrar la ventana cerraba la aplicación en lugar de minimizarla a la bandeja.

## [1.0.0] - 2025-12-25

### Añadido
- **Drag & Drop**: Arrastre archivos a la estantería flotante.
- **Drag Out**: Mueva archivos recolectados en lote a cualquier destino.
- **Experiencia Nativa**: Construido con `macos_ui` para una integración total con el sistema.
- **Localización**: Soporte para Inglés, Portugués y Español.
