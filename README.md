<<<<<<< HEAD
# SportUnity - Plataforma de Comunidades Deportivas Inclusivas

## 🚀 Inicio Rápido

### 1. Instalar dependencias
```bash
flutter pub get
```

### 2. Configurar variables de entorno
```bash
cp .env.example .env
```
Edita `.env` y añade tus credenciales de Supabase:
- `SUPABASE_URL`: URL de tu proyecto Supabase
- `SUPABASE_ANON_KEY`: Clave anónima de Supabase

### 3. Ejecutar la app
```bash
flutter run -d chrome  # Web
flutter run -d android # Android
flutter run -d ios     # iOS
```

---

## 📁 Estructura del Proyecto

```
lib/
├── core/          # Inyección de dependencias (Service Locator)
├── data/          # Datasources, modelos, repositorios
├── domain/        # Entidades, repositorios abstractos, usecases
├── presentation/  # ViewModels, páginas, widgets
└── main.dart      # Punto de entrada
```

### Arquitectura
- **Clean Architecture** con 3 capas: Domain, Data, Presentation
- **Patrón MVVM** para gestión de estado
- **Provider** para inyección de dependencias

---

## ✨ Características Implementadas

✅ Autenticación (sign-up, sign-in, sign-out)
✅ Crear actividades deportivas con foto y ubicación validada
✅ Mapa interactivo con marcadores por deporte
✅ Ver detalle de actividades
✅ Eliminar actividades
✅ Filtros por deporte, nivel y tiempo
✅ 15 deportes diferentes con iconos únicos

---

## 🔧 Stack Tecnológico

- **Frontend**: Flutter + Dart
- **Backend**: Supabase (PostgreSQL)
- **Mapas**: Flutter Map + OpenStreetMap
- **Geolocalización**: Nominatim API
- **Autenticación**: Supabase Auth

---

## 📝 Notas Importantes

- El `.env` NO se incluye en Git (está en `.gitignore`)
- Asegúrate de crear la tabla `activities` en Supabase con la estructura correcta
- Las imágenes se guardan en Supabase Storage (`activity-images` bucket)

---

## 👥 Colaboración

Este proyecto sigue una estructura de ramas por feature:

```
main (versión base)
├── feature/auth              (Autenticación)
├── feature/home              (Feed + Mapa)
└── feature/create-activity   (Creación de actividades)
```

Cada persona trabaja en su rama y hace PR a `main` cuando termina.

---

**¡Bienvenido al equipo! 🚀**
=======
# Sport Unity

App para compartir actividades deportivas con mapa y ubicación.

## Setup

1. `flutter pub get`
2. Copia `.env.example` a `.env` y añade tus credenciales de Supabase
3. `flutter run`

## Tecnología

- Flutter + Dart
- Supabase (auth + database + storage)
- Provider para state management
- Flutter Map

## Features

- Autenticación con Supabase
- Crear actividades con foto y ubicación
- Mapa interactivo
- Ver detalles de actividades
- Filtros (deporte, nivel, tiempo)
- Perfil de usuario
- Añadir amigos para ver actividades


## Notas

- El .env no está en git
- Las tablas de Supabase tienen que estar creadas (activities, profiles, etc)
- Las fotos se guardan en el bucket activity-images
>>>>>>> jacahi
