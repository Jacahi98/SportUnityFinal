import '../../domain/entities/sport_activity.dart';

class SportActivityModel extends SportActivity {
  const SportActivityModel({
    required super.id,
    super.title,
    required super.sport,
    required super.level,
    required super.description,
    required super.latitude,
    required super.longitude,
    required super.photos,
    required super.createdAt,
    super.location,
    super.imageUrl,
  });

  factory SportActivityModel.fromEntity(SportActivity activity) {
    return SportActivityModel(
      id: activity.id,
      title: activity.title,
      sport: activity.sport,
      level: activity.level,
      description: activity.description,
      latitude: activity.latitude,
      longitude: activity.longitude,
      photos: activity.photos,
      createdAt: activity.createdAt,
      location: activity.location,
      imageUrl: activity.imageUrl,
    );
  }

  factory SportActivityModel.fromMap(Map<String, dynamic> map) {
    return SportActivityModel(
      id: map['id'] as String,
      title: map['title'] as String?,
      sport: map['sport'] as String? ?? '',
      level: map['level'] as String? ?? '',
      description: map['description'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      photos: const [],
      createdAt: DateTime.parse(map['created_at'] as String),
      location: map['location'] as String?,
      imageUrl: map['image_url'] as String?,
    );
  }
}
