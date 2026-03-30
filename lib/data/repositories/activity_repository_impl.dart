import '../../domain/entities/sport_activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_supabase_datasource.dart';
import '../models/sport_activity_model.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  ActivityRepositoryImpl(this._dataSource);

  final ActivitySupabaseDataSource _dataSource;

  @override
  Future<List<SportActivity>> getActivities() {
    return _dataSource.getActivities();
  }

  @override
  Future<void> publishActivity(SportActivity activity, {required String title, required String location}) {
    final model = SportActivityModel.fromEntity(activity);
    return _dataSource.publishActivity(model, title: title, location: location);
  }

  @override
  Future<void> deleteActivity(String activityId) {
    return _dataSource.deleteActivity(activityId);
  }
}
