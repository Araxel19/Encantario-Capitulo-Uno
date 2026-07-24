# 💖 Encantario: Capítulo Uno

**Encantario: Capítulo Uno** es una aplicación móvil construida en **Flutter** diseñada para acompañar a una pareja a través de un viaje interactivo de **30 días de retos, trivias, minijuegos y preguntas de conexión**. 

El objetivo es compartir momentos especiales, conocer aspectos divertidos y profundos del otro día a día, y avanzar por un camino serpenteante cósmico hasta el **Día 30**.

---

## ✨ Características Principales

- 🗺️ **Camino Serpenteante Ascendente (30 Días)**:
  - Diseño dinámico de progreso de abajo hacia arriba (Día 1 al Día 30).
  - Nodos visuales diferenciados: bloqueados con candado 🔒, disponibles 🔓 y completados con insignia de verificación ✔️.
  - Día 30 enigmático (`✨ El Gran Secreto`) para conservar la sorpresa hasta el momento final.

- 🌌 **Fondo Cósmico Animado**:
  - Campo de más de 90 estrellas parpadeantes y nebulosas ambientales dibujadas mediante `CustomPainter` fluido.

- 🕹️ **Minijuegos Arcade Divertidos**:
  - **Memoria 3x3 (`memory_match`)**: Cuadrícula de 9 tarjetas con 4 parejas y 1 carta comodín de estrella brillante.
  - **Reflejos Mágicos (`gem_catcher`)**: Desafío de agilidad atrapando destellos brillantes en movimiento.
  - **Descifra el Código (`word_scramble`)**: Ordenamiento táctil de fichas para resolver palabras clave secretas.

- 📷 **Carga de Fotos y Recursos**:
  - Permite adjuntar imágenes o recuerdos desde la galería en cada reto.

- 📲 **Integración con WhatsApp**:
  - Comparte fácilmente tus respuestas junto con la foto o recurso adjunto directamente por WhatsApp.

- 🐱 **Gato Asistente Flotante**:
  - Avatar flotante animado que ofrece consejos útiles al interactuar.

- 📅 **Control de Calendario Real y Modo Pruebas**:
  - Limita el desbloqueo a **1 día por fecha real** para llevar el ritmo del mes.
  - Incluye un interruptor de **Modo Pruebas (Dev Mode)** en el encabezado para probar todos los días inmediatamente.

- 🕊️ **Declaración Final del Día 30 Sin Presión**:
  - Presenta opciones claras y respetuosas para aceptar o declinar sin forzar decisiones.

---

## 🚀 Tecnologías Utilizadas

- **Framework**: [Flutter](https://flutter.dev/) (Dart SDK `^3.12.2`)
- **Gestión de Estado y Persistencia**: `shared_preferences`
- **Animaciones Lottie**: `lottie`
- **Carga de Archivos e Imágenes**: `image_picker`
- **Compartido Nativo**: `share_plus`
- **Paquete Android**: `com.encantario.capitulo_uno`
- **Versión**: `0.1.0+1`

---

## 🛠️ Instalación y Compilación

### Requisitos Previos
- Flutter SDK instalado y configurado.
- Android Studio / VS Code con extensión de Flutter.
- Dispositivo Android con depuración USB activada.

### Pasos
1. Clonar el repositorio:
   ```bash
   git clone https://github.com/tu-usuario/encantario_capitulo_uno.git
   cd encantario_capitulo_uno
   ```

2. Obtener las dependencias:
   ```bash
   flutter pub get
   ```

3. Ejecutar en tu dispositivo móvil:
   ```bash
   flutter run
   ```

4. Compilar APK de producción:
   ```bash
   flutter build apk --release
   ```

---

## 📁 Estructura del Proyecto

```text
lib/
├── constants/
│   └── app_assets.dart         # Constantes de rutas de imágenes y animaciones Lottie
├── data/
│   └── challenges_data.dart    # Lista de los 30 retos, trivias y minijuegos
├── models/
│   └── day_challenge.dart      # Modelo de datos de los retos y progreso
├── screens/
│   ├── home_screen.dart        # Pantalla principal con camino serpenteante y progreso
│   └── splash_screen.dart      # Pantalla de carga inicial con animación Lottie
└── widgets/
    ├── confession_dialog.dart  # Diálogo final del Día 30
    ├── day_detail_dialog.dart  # Cuadro de diálogo interactivo de cada día
    ├── day_node_widget.dart    # Renderizado visual de los nodos en la ruta
    ├── helper_avatar_widget.dart # Avatar flotante del gato asistente
    ├── minigames_widget.dart   # Componentes de minijuegos arcade
    ├── snake_path_painter.dart # Pintado de línea serpenteante interactiva
    └── starry_background.dart # Fondo cósmico animado con estrellas
```

---

## 📄 Licencia

Este proyecto está bajo la licencia MIT.
