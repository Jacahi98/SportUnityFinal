import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sport_activity_model.dart';

class ActivitySupabaseDataSource {
  ActivitySupabaseDataSource(this._client);

  final SupabaseClient _client;

  Future<List<SportActivityModel>> getActivities() async {
    final response = await _client
        .from('activities')
        .select('*, user_id')
        .order('created_at', ascending: false);

    return response.map((row) => SportActivityModel.fromMap(row)).toList();
  }

  Future<void> publishActivity(SportActivityModel activity, {required String title, required String location}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
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
      'tags': activity.tags,
    };

    await _client.from('activities').insert(activityData);
  }

  Future<void> deleteActivity(String activityId) async {
    await _client.from('activities').delete().eq('id', activityId);
  }
}
