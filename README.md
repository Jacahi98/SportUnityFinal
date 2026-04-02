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

## Problemas conocidos

- Las imágenes a veces no cargan bien en web (problema con codec)
- El geocoding puede ser lento si Nominatim está saturado

## Notas

- El .env no está en git
- Las tablas de Supabase tienen que estar creadas (activities, profiles, etc)
- Las fotos se guardan en el bucket activity-images
