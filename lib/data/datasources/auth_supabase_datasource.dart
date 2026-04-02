<<<<<<< HEAD
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
          await _client.from('users').insert({
            'id': response.user!.id,
            'email': email,
            'full_name': '',
            'avatar_url': null,
          });
        } catch (e) {
          throw Exception('Usuario creado en Supabase Auth pero error al guardar perfil: $e');
        }
      } else {
        throw Exception('No se pudo crear la cuenta en Supabase Auth');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
=======
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
          await _client.from('users').insert({
            'id': response.user!.id,
            'email': email,
            'full_name': '',
            'avatar_url': null,
          });
        } catch (e) {
          throw Exception('Usuario creado en Supabase Auth pero error al guardar perfil: $e');
        }
      } else {
        throw Exception('No se pudo crear la cuenta en Supabase Auth');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
>>>>>>> jacahi
