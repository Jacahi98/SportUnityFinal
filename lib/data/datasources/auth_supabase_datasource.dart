import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSupabaseDataSource {
  AuthSupabaseDataSource(this._client);

  final SupabaseClient _client;

  bool get isLoggedIn => _client.auth.currentSession != null;

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      if (e.toString().contains('Invalid login credentials')) {
        throw Exception('Correo o contraseña incorrectos');
      }
      rethrow;
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    try {
      final response = await _client.auth.signUp(email: email, password: password);

      if (response.user != null) {
        try {
          // Usar upsert para evitar conflicto si el trigger ya creó el perfil
          await _client.from('profiles').upsert({
            'id': response.user!.id,
            'alias': 'Usuario_${response.user!.id.substring(0, 8)}',
            'avatar_url': null,
          });
        } catch (e) {
          // Si falla, el trigger probablemente ya creó el perfil
          print('Advertencia al actualizar perfil: $e');
        }
      } else {
        throw Exception('No se pudo crear la cuenta en Supabase Auth');
      }
    } catch (e) {
      throw Exception('Error en signup: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
