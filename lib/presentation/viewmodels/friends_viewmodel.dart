import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FriendsViewModel extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _friends = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get searchResults => _searchResults;
  List<Map<String, dynamic>> get pendingRequests => _pendingRequests;
  List<Map<String, dynamic>> get friends => _friends;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? get _currentUserId => _client.auth.currentUser?.id;

  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_currentUserId == null) {
        _errorMessage = 'Usuario no autenticado';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final results = await _client
          .from('profiles')
          .select()
          .neq('id', _currentUserId!)
          .limit(10);

      final List<Map<String, dynamic>> filtered = [];
      for (final user in results as List) {
        final alias = user['alias'] as String?;
        if (alias != null && alias.toLowerCase().contains(query.toLowerCase())) {
          filtered.add(user);
        }
      }

      _searchResults = filtered;
    } catch (e) {
      _errorMessage = 'Error en búsqueda: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendRequest(String receiverId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _client.from('friendships').insert({
        'sender_id': _currentUserId,
        'receiver_id': receiverId,
        'status': 'pending',
      });

      _searchResults.removeWhere((u) => u['id'] == receiverId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al enviar solicitud: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> loadPendingRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_currentUserId == null) {
        _errorMessage = 'Usuario no autenticado';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final requests = await _client
          .from('friendships')
          .select('id, sender_id, status')
          .eq('receiver_id', _currentUserId!)
          .eq('status', 'pending');

      // Cargar perfiles de los senders
      final List<Map<String, dynamic>> requestsWithProfiles = [];
      for (final req in requests as List) {
        final senderId = req['sender_id'] as String;
        final profile = await _client
            .from('profiles')
            .select('id, alias')
            .eq('id', senderId)
            .single();

        requestsWithProfiles.add({
          ...req,
          'profiles': profile,
        });
      }

      _pendingRequests = requestsWithProfiles;
    } catch (e) {
      _errorMessage = 'Error al cargar solicitudes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptRequest(String friendshipId) async {
    try {
      await _client
          .from('friendships')
          .update({'status': 'accepted'}).eq('id', friendshipId);

      _pendingRequests.removeWhere((r) => r['id'] == friendshipId);
      await loadFriends();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al aceptar: $e';
      notifyListeners();
    }
  }

  Future<void> rejectRequest(String friendshipId) async {
    try {
      await _client.from('friendships').delete().eq('id', friendshipId);

      _pendingRequests.removeWhere((r) => r['id'] == friendshipId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al rechazar: $e';
      notifyListeners();
    }
  }

  Future<void> loadFriends() async {
    try {
      if (_currentUserId == null) {
        _friends = [];
        notifyListeners();
        return;
      }

      final result = await _client.rpc('get_friends', params: {'user_id': _currentUserId});
      if (result is List) {
        _friends = List<Map<String, dynamic>>.from(result);
      } else {
        _friends = [];
      }
      notifyListeners();
    } catch (e) {
      _friends = [];
      notifyListeners();
    }
  }
}
