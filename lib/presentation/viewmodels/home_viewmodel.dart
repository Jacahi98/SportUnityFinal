import 'package:flutter/foundation.dart';

import '../../domain/entities/sport_activity.dart';
import '../../domain/usecases/get_activities_usecase.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._getActivitiesUseCase);

  final GetActivitiesUseCase _getActivitiesUseCase;

  List<SportActivity> _activities = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filtros
  String _timeFilter = '24h'; // '1h', '24h', '7d', 'all'
  String? _sportFilter;
  String? _levelFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get timeFilter => _timeFilter;
  String? get sportFilter => _sportFilter;
  String? get levelFilter => _levelFilter;

  List<SportActivity> get activities {
    var filtered = _activities;

    // Filtro temporal (muestra próximas X horas/días)
    if (_timeFilter != 'all') {
      final now = DateTime.now();
      final Duration duration;
      switch (_timeFilter) {
        case '1h':
          duration = const Duration(hours: 1);
        case '7d':
          duration = const Duration(days: 7);
        default:
          duration = const Duration(hours: 24);
      }
      final futureLimit = now.add(duration);
      filtered = filtered.where((a) => a.createdAt.isAfter(now) && a.createdAt.isBefore(futureLimit)).toList();
    }

    if (_sportFilter != null) {
      filtered = filtered.where((a) => a.sport == _sportFilter).toList();
    }

    if (_levelFilter != null) {
      filtered = filtered.where((a) => a.level == _levelFilter).toList();
    }

    return filtered;
  }

  void setTimeFilter(String filter) {
    _timeFilter = filter;
    notifyListeners();
  }

  void setSportFilter(String? sport) {
    _sportFilter = sport;
    notifyListeners();
  }

  void setLevelFilter(String? level) {
    _levelFilter = level;
    notifyListeners();
  }

  Future<void> loadActivities() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activities = await _getActivitiesUseCase();
    } catch (e) {
      _errorMessage = 'Error al cargar actividades: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
