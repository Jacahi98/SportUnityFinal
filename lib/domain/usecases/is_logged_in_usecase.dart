import '../repositories/auth_repository.dart';

class IsLoggedInUseCase {
  IsLoggedInUseCase(this._repository);

  final AuthRepository _repository;

  bool call() {
    return _repository.isLoggedIn;
  }
}
