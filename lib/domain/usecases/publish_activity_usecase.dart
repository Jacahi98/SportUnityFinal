<<<<<<< HEAD
import '../entities/sport_activity.dart';
import '../repositories/activity_repository.dart';

class PublishActivityUseCase {
  PublishActivityUseCase(this._repository);

  final ActivityRepository _repository;

  Future<void> call(SportActivity activity, {required String title, required String location}) {
    return _repository.publishActivity(activity, title: title, location: location);
  }
}
=======
import '../entities/sport_activity.dart';
import '../repositories/activity_repository.dart';

class PublishActivityUseCase {
  PublishActivityUseCase(this._repository);

  final ActivityRepository _repository;

  Future<void> call(SportActivity activity, {required String title, required String location}) {
    return _repository.publishActivity(activity, title: title, location: location);
  }
}
>>>>>>> jacahi
