import 'package:flutter/foundation.dart';

import '../../domain/entities/sport_activity.dart';
import '../../domain/usecases/get_activities_usecase.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._getActivitiesUseCase);

  final GetActivitiesUseCase _getActivitiesUseCase;

  List<SportActivity> _activities = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SportActivity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
