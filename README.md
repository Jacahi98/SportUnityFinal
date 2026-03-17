# SportUnity

Aplicación móvil Flutter para crear y descubrir actividades deportivas en un mapa interactivo.

## Características

- Autenticación con email y contraseña usando Supabase
- Mapa interactivo con OpenStreetMap
- Crear actividades deportivas con ubicación, fecha y hora
- Ver actividades de otros usuarios en el mapa
- Seleccionar ubicación en mapa al crear actividades

## Requisitos

- Flutter 3.10+
- Dart 3.10+
- Supabase account

## Instalación

1. Clona el repositorio
2. Copia `.env.example` a `.env` y completa con tus credenciales de Supabase
3. Ejecuta `flutter pub get`
4. En Supabase, ejecuta el SQL en `supabase/schema.sql`
5. Ejecuta `flutter run`

## Estructura

```
lib/
  ├── main.dart                 # Punto de entrada
  ├── screens/
  │   ├── login_screen.dart     # Pantalla de autenticación
  │   ├── map_screen.dart       # Pantalla principal con mapa
  │   └── add_activity_screen.dart  # Crear nueva actividad
  └── services/
      └── supabase_service.dart # Servicio de Supabase
```

