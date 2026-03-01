<div align="center">

<img src="https://raw.githubusercontent.com/victorcmarinho/EasierDrop/main/assets/icon/icon.png" width="128" alt="Easier Drop Icon">

# Easier Drop

**El estante de "arrastrar y soltar" que faltaba en macOS.**

[🇺🇸 English](README.md) | [🇧🇷 Português](README_pt.md) | [🇪🇸 Español](README_es.md)

[**🌐 Sitio web**](https://victorcmarinho.github.io/EasierDrop/)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)](https://www.apple.com/macos/)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)](https://flutter.dev)

</div>

## 🚀 ¿Por qué Easier Drop?

**¿Alguna vez has sentido la frustración de arrastrar un archivo solo para darte cuenta de que la aplicación de destino está oculta detrás de tres ventanas más?** 

Easier Drop es tu compañero nativo de productividad para macOS que termina con la locura de intercambiar ventanas. Proporciona un **estante temporal**: una zona flotante donde puedes "guardar" cualquier cosa (archivos, imágenes, texto) de cualquier aplicación. Reúne tu pila, navega libremente y suelta todo a la vez quando estés listo.

> **Es como un estante físico para tu flujo de trabajo digital. Gratuito, de código abierto y nativamente rápido.**

---

## ✨ Funcionalidades Increíbles (v1.1.2)

### 📦 Recolecta en cualquier lugar, al instante
Arrastra desde Finder, Safari, Fotos o incluso tu editor de código. Tus archivos se quedan guardados hasta que estés listo para moverlos.
> ![Recolectando Archivos](https://raw.githubusercontent.com/victorcmarinho/EasierDrop/main/assets/promo/useged-2.png)
> *Guarda archivos de múltiples fuentes en una sola pila organizada.*

### 🛠️ Magia Multi-Ventana
¿Necesitas mantener pilas separadas para diferentes proyectos? Abre múltiples ventanas de Easier Drop en cualquier lugar de tu pantalla.
> ![Soporte Multi-Ventana](https://raw.githubusercontent.com/victorcmarinho/EasierDrop/main/assets/promo/multi_window.png)
> *Productividad duplicada: gestiona diferentes pilas para diferentes tareas.*

### 🤝 Agitar para Seleccionar (Native Shake)
¿Sientes el "sacudida"? Solo agita tu ratón mientras arrastras un archivo para crear instantáneamente una nueva ventana de Easier Drop exactamente en tu cursor.
> ![Gesto de Agitar](https://raw.githubusercontent.com/victorcmarinho/EasierDrop/main/assets/promo/shake_gesture.gif)
> *La forma más natural de crear una zona de drop rápidamente.*

### 📋 Integración con el Portapapeles
¿Ya has copiado algo? Solo presiona `Cmd + V` sobre la zona de drop para añadirlo a tu estante. Integración perfecta con Finder y los portapapeles del sistema.
> ![Integración con el Portapapeles](https://raw.githubusercontent.com/victorcmarinho/EasierDrop/main/assets/promo/demo.webp)
> *Pega archivos directamente en tu flujo de trabajo sin necesidad de arrastrar de nuevo.*

### 💎 Configuración Personalizable
Una ventana de preferencias completa para ajustar Easier Drop a tu flujo de trabajo. Calibra la sensibilidad del gesto de agitar, controla la opacidad de la ventana y gestiona opciones como "Siempre Visible" o "Abrir al Iniciar Sesión".
> ![Interfaz de Configuración](https://raw.githubusercontent.com/victorcmarinho/EasierDrop/main/assets/promo/settings_ui.png)
> *Personaliza cada detalle de tus zonas de drop para una máxima productividad.*

### ⚡️ Siempre Visible y Velocidad Nativa
Creado con Flutter y ganchos nativos de macOS, Easier Drop es increíblemente ligero y permanece visible sobre tu trabajo para que siempre esté ahí cuando lo necesites.

---

## 🛠 Instalación

### Descargar App
[**Descargar Última Versión**](https://github.com/victorcmarinho/EasierDrop/releases)

### Homebrew
También puedes instalar a través de Homebrew:

```bash
brew tap victorcmarinho/easier-drop https://github.com/victorcmarinho/EasierDrop
brew install --cask easier-drop
```

> **Nota:** Si la aplicación no se abre con un error de "dañado" (común en instalaciones vía Homebrew de apps no notariadas), ejecuta este comando en la terminal:
> ```bash
> xattr -d com.apple.quarantine "/Applications/Easier Drop.app"
> ```

---

## ⌨️ Atajos Pro

- `Cmd + V`: Pega archivos copiados directamente en el estante.
- `Cmd + Backspace`: Limpia todo el estante.
- `Cmd + C`: Copia todos los elementos del estante de nuevo al portapapeles.
- `Cmd + Shift + C`: Comparte elementos rápidamente a través del Menú de Compartir de macOS.
- `Cmd + ,`: Abre las Preferencias.

---

## 🤝 Contribuyendo

¡Nos encantan los colaboradores! 
1. **Fork** el proyecto.
2. **Crea** tu rama de funcionalidad (feature branch).
3. **Envía** un Pull Request.

## 📄 Licencia

Distribuido bajo la Licencia MIT. Ver `LICENSE` para más información.

---

## 🛠️ Información Técnica

### Cómo Funciona
Easier Drop está desarrollado como una aplicación de escritorio para macOS que aprovecha Flutter para la interfaz de usuario y las API nativas de macOS para la integración con el sistema.
- **Lógica de Arrastrar y Soltar**: Utiliza platform channels y el paquete `desktop_multi_window` para gestionar múltiples instancias de ventanas.
- **Gestión de Estado**: Utiliza el patrón `Provider` para sincronizar archivos entre múltiples ventanas en tiempo real.
- **Integración Nativa**: Implementa un `MacOSShakeMonitor` personalizado mediante ganchos nativos de Swift para detectar el gesto de agitar durante el arrastre.
- **Persistencia**: Las referencias de archivos se gestionan en memoria para mayor velocidad, con validación de rutas efímeras para asegurar la integridad de los datos.

### Tecnologías Utilizadas
- **Framework**: [Flutter](https://flutter.dev) (macOS Desktop)
- **Lenguaje**: Dart y Swift (para ganchos nativos)
- **Gestión de Estado**: Provider
- **Telemetría**: Aptabase
- **Componentes de UI**: `macos_ui` para una apariencia nativa

### Cómo Ejecutar el Proyecto
Para ejecutar el proyecto localmente:
1. Asegúrate de tener instalado el [SDK de Flutter](https://docs.flutter.dev/get-started/install/macos).
2. Clona el repositorio.
3. Instala las dependencias:
   ```bash
   flutter pub get
   ```
4. Crea un archivo `.env` basado en `.env.example`:
   ```bash
   cp .env.example .env
   ```
5. Ejecuta la aplicación:
   ```bash
   flutter run -d macos
   ```

### Ejecución de Pruebas
Mantenemos la calidad del código con un conjunto completo de pruebas unitarias.
Para ejecutar las pruebas:
```bash
flutter test
```
Para comprobar la cobertura:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Variables de Entorno
El proyecto utiliza archivos `.env` para la configuración:
- `APTABASE_APP_KEY`: Tu clave de telemetría de Aptabase.
- `GITHUB_LATEST_RELEASE_URL`: Punto de enlace de la API para las comprobaciones de actualización.

## ❤️ Apoya el Proyecto

Si Easier Drop hace tu vida más fácil, ¡considera apoyar al desarrollador!

<div align="center">
  <a href="https://github.com/sponsors/victorcmarinho">
    <img src="https://img.shields.io/badge/Sponsor-❤️-pink?style=for-the-badge" alt="Sponsor">
  </a>
</div>
