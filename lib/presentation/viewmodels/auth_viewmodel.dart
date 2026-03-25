import 'package:flutter/foundation.dart';

import '../../domain/usecases/is_logged_in_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(
    this._isLoggedInUseCase,
    this._signInUseCase,
    this._signUpUseCase,
    this._signOutUseCase,
  );

  final IsLoggedInUseCase _isLoggedInUseCase;
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void init() {
    _isLoggedIn = _isLoggedInUseCase();
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _signInUseCase(email: email, password: password);
      _isLoggedIn = true;
      return true;
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('429')) {
        _errorMessage = 'Demasiados intentos. Espera un momento.';
      } else if (errorStr.contains('Invalid login credentials')) {
        _errorMessage = 'Correo o contraseña incorrectos.';
      } else {
        _errorMessage = 'Error al iniciar sesión.';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({required String email, required String password}) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _signUpUseCase(email: email, password: password);
      _isLoggedIn = true;
      return true;
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('429')) {
        _errorMessage = 'Demasiados intentos. Espera un momento.';
      } else if (errorStr.contains('email')) {
        _errorMessage = 'El correo ya está registrado.';
      } else {
        _errorMessage = 'Error al crear cuenta.';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _signOutUseCase();
    _isLoggedIn = false;
    _errorMessage = null;
    notifyListeners();
  }
}
