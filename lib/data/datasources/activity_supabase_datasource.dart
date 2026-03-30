import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sport_activity_model.dart';

class ActivitySupabaseDataSource {
  ActivitySupabaseDataSource(this._client);

  final SupabaseClient _client;

  Future<List<SportActivityModel>> getActivities() async {
    final response = await _client
        .from('activities')
        .select()
        .order('created_at', ascending: false);

    return response.map((row) => SportActivityModel.fromMap(row)).toList();
  }

  Future<void> publishActivity(SportActivityModel activity, {required String title, required String location}) async {
    print('[ActivitySupabaseDataSource] publishActivity iniciado');

    final userId = _client.auth.currentUser?.id;
    print('[ActivitySupabaseDataSource] userId: $userId');

    if (userId == null) {
      print('[ActivitySupabaseDataSource] ERROR: userId es null');
      throw const AuthException('Debes iniciar sesión para publicar.');
    }

    final activityData = {
      'user_id': userId,
      'title': title,
      'sport': activity.sport,
      'level': activity.level,
      'description': activity.description,
      'latitude': activity.latitude,
      'longitude': activity.longitude,
      'location': location,
      'image_url': activity.imageUrl,
      'created_at': activity.createdAt.toIso8601String(),
    };

    print('[ActivitySupabaseDataSource] Datos a insertar: $activityData');

    try {
      final response = await _client.from('activities').insert(activityData);
      print('[ActivitySupabaseDataSource] Éxito, respuesta: $response');
    } catch (e) {
      print('[ActivitySupabaseDataSource] Error: $e');
      rethrow;
    }
  }

  Future<void> deleteActivity(String activityId) async {
    print('[ActivitySupabaseDataSource] Eliminando actividad: $activityId');

    try {
      await _client.from('activities').delete().eq('id', activityId);
      print('[ActivitySupabaseDataSource] Actividad eliminada con éxito');
    } catch (e) {
      print('[ActivitySupabaseDataSource] Error eliminando actividad: $e');
      rethrow;
    }
  }
}
