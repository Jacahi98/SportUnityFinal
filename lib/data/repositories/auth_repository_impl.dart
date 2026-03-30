import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_supabase_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final AuthSupabaseDataSource _dataSource;

  @override
  bool get isLoggedIn => _dataSource.isLoggedIn;

  @override
  Future<void> signIn({required String email, required String password}) {
    return _dataSource.signIn(email: email, password: password);
  }

  @override
  Future<void> signUp({required String email, required String password}) {
    return _dataSource.signUp(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }
}
