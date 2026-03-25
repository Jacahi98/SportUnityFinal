import '../models/sport_activity_model.dart';

class ActivityInMemoryDataSource {
  final List<SportActivityModel> _activities = [
    SportActivityModel(
      id: 'demo-1',
      sport: 'Fútbol',
      level: 'Intermedio',
      description: 'Partido rápido esta tarde en el polideportivo.',
      latitude: 40.4167,
      longitude: -3.70325,
      photos: [],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  Future<List<SportActivityModel>> getActivities() async {
    return List.unmodifiable(_activities.reversed);
  }

  Future<void> publishActivity(SportActivityModel activity) async {
    _activities.add(activity);
  }
}
