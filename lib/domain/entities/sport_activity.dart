import 'dart:typed_data';

class SportActivity {
  const SportActivity({
    required this.id,
    this.title,
    required this.sport,
    required this.level,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.photos,
    required this.createdAt,
    this.location,
    this.imageUrl,
  });

  final String id;
  final String? title;
  final String sport;
  final String level;
  final String description;
  final double latitude;
  final double longitude;
  final List<Uint8List> photos;
  final DateTime createdAt;
  final String? location;
  final String? imageUrl;
}
