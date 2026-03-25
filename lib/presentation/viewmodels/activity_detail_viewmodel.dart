import 'package:flutter/foundation.dart';

import '../../domain/usecases/delete_activity_usecase.dart';

class ActivityDetailViewModel extends ChangeNotifier {
  ActivityDetailViewModel(this._deleteActivityUseCase);

  final DeleteActivityUseCase _deleteActivityUseCase;

  bool _isDeleting = false;
  String? _errorMessage;

  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;

  Future<bool> deleteActivity(String activityId) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _deleteActivityUseCase(activityId);
      _isDeleting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar actividad: ${e.toString()}';
      _isDeleting = false;
      notifyListeners();
      return false;
    }
  }
}
