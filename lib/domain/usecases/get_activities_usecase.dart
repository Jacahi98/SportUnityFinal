<<<<<<< HEAD
import '../entities/sport_activity.dart';
import '../repositories/activity_repository.dart';

class GetActivitiesUseCase {
  GetActivitiesUseCase(this._repository);

  final ActivityRepository _repository;

  Future<List<SportActivity>> call() {
    return _repository.getActivities();
  }
}
=======
import '../entities/sport_activity.dart';
import '../repositories/activity_repository.dart';

class GetActivitiesUseCase {
  GetActivitiesUseCase(this._repository);

  final ActivityRepository _repository;

  Future<List<SportActivity>> call() {
    return _repository.getActivities();
  }
}
>>>>>>> jacahi
