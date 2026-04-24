import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/sport_activity.dart';
import '../../domain/usecases/publish_activity_usecase.dart';

class CreateActivityViewModel extends ChangeNotifier {
  CreateActivityViewModel(this._publishActivityUseCase);

  final PublishActivityUseCase _publishActivityUseCase;
  final Uuid _uuid = const Uuid();

  bool _isSubmitting = false;
  String? _errorMessage;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<bool> publishActivity({
    required String sport,
    required String level,
    required String title,
    required String description,
    XFile? imageFile,
    required DateTime dateTime,
    required String location,
    required double latitude,
    required double longitude,
    required List<String> tags,
  }) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _errorMessage = 'No estás autenticado';
        return false;
      }

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, user.id);
      }

      final activity = SportActivity(
        id: _uuid.v4(),
        sport: sport,
        level: level,
        description: description,
        latitude: latitude,
        longitude: longitude,
        photos: [],
        createdAt: DateTime.now(),
        eventDateTime: dateTime,
        imageUrl: imageUrl,
        tags: tags,
      );

      await _publishActivityUseCase(activity, title: title, location: location);
      return true;
    } catch (e) {
      _errorMessage = 'Error: ${e.toString().split('\n').first}';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<String> _uploadImage(XFile imageFile, String userId) async {
    final fileName = '${const Uuid().v4()}.jpg';
    final filePath = '$userId/$fileName';

    final bytes = await imageFile.readAsBytes();
    await Supabase.instance.client.storage.from('activity-images').uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

    final publicUrl = Supabase.instance.client.storage.from('activity-images').getPublicUrl(filePath);
    return publicUrl;
  }
}
