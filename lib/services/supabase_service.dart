import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  Future<void> signUp(String email, String password) async {
    await client.auth.signUp(email: email, password: password);
  }

  Future<void> signIn(String email, String password) async {
    await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? getCurrentUser() {
    return client.auth.currentUser;
  }

  Future<List<Map<String, dynamic>>> getActividades() async {
    final response = await client
        .from('actividades')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> insertActividad({
    required String titulo,
    required String deporte,
    required String descripcion,
    required String fecha,
    required String hora,
    required double latitud,
    required double longitud,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    await client.from('actividades').insert({
      'user_id': userId,
      'titulo': titulo,
      'deporte': deporte,
      'descripcion': descripcion,
      'fecha': fecha,
      'hora': hora,
      'latitud': latitud,
      'longitud': longitud,
    });
  }

  Future<void> deleteActividad(int id) async {
    await client.from('actividades').delete().eq('id', id);
  }
}
