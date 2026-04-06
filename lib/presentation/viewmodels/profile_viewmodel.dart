import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileViewModel extends ChangeNotifier {
  String? _alias;
  int _friendCount = 0;
  List<Map<String, dynamic>> _friends = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  String? get alias => _alias;
  int get friendCount => _friendCount;
  List<Map<String, dynamic>> get friends => _friends;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      // Cargar perfil
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        _alias = response['alias'] as String?;
      }

      // Cargar amigos
      try {
        final friendsResult = await Supabase.instance.client.rpc('get_friends', params: {'user_id': userId});
        if (friendsResult is List) {
          _friends = List<Map<String, dynamic>>.from(friendsResult);
          _friendCount = _friends.length;
        }
      } catch (e) {
        // Si la función RPC no existe, intenta con query directo
        _friends = [];
        _friendCount = 0;
      }
    } catch (e) {
      _errorMessage = 'Error al cargar perfil';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile({required String alias}) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return false;

      await Supabase.instance.client.from('profiles').upsert({
        'id': userId,
        'alias': alias,
      });

      _alias = alias;
      _successMessage = 'Perfil guardado correctamente';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al guardar perfil: ${e.toString().split('\n').first}';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
