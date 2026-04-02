import '../repositories/activity_repository.dart';

class DeleteActivityUseCase {
  DeleteActivityUseCase(this._repository);

  final ActivityRepository _repository;

  Future<void> call(String activityId) {
    return _repository.deleteActivity(activityId);
  }
}
