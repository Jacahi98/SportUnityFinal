import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/activity_supabase_datasource.dart';
import '../../data/datasources/auth_supabase_datasource.dart';
import '../../data/repositories/activity_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/delete_activity_usecase.dart';
import '../../domain/usecases/get_activities_usecase.dart';
import '../../domain/usecases/is_logged_in_usecase.dart';
import '../../domain/usecases/publish_activity_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';

class ServiceLocator {
  final SupabaseClient _client = Supabase.instance.client;

  late final ActivitySupabaseDataSource _activityDataSource =
      ActivitySupabaseDataSource(_client);

  late final AuthSupabaseDataSource _authDataSource = AuthSupabaseDataSource(
    _client,
  );

  late final ActivityRepositoryImpl _activityRepository =
      ActivityRepositoryImpl(_activityDataSource);

  late final AuthRepositoryImpl _authRepository = AuthRepositoryImpl(
    _authDataSource,
  );

  late final GetActivitiesUseCase getActivitiesUseCase = GetActivitiesUseCase(
    _activityRepository,
  );

  late final PublishActivityUseCase publishActivityUseCase =
      PublishActivityUseCase(_activityRepository);

  late final DeleteActivityUseCase deleteActivityUseCase =
      DeleteActivityUseCase(_activityRepository);

  late final SignInUseCase signInUseCase = SignInUseCase(_authRepository);

  late final SignUpUseCase signUpUseCase = SignUpUseCase(_authRepository);

  late final SignOutUseCase signOutUseCase = SignOutUseCase(_authRepository);

  late final IsLoggedInUseCase isLoggedInUseCase = IsLoggedInUseCase(
    _authRepository,
  );
}
