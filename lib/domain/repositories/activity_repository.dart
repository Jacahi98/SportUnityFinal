<<<<<<< HEAD
import '../entities/sport_activity.dart';

abstract class ActivityRepository {
  Future<List<SportActivity>> getActivities();

  Future<void> publishActivity(SportActivity activity, {required String title, required String location});

  Future<void> deleteActivity(String activityId);
}
=======
import '../entities/sport_activity.dart';

abstract class ActivityRepository {
  Future<List<SportActivity>> getActivities();

  Future<void> publishActivity(SportActivity activity, {required String title, required String location});

  Future<void> deleteActivity(String activityId);
}
>>>>>>> jacahi
