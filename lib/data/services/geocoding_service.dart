import 'package:http/http.dart' as http;
import 'dart:convert';

class GeocodingResult {
  final double latitude;
  final double longitude;
  final String displayName;

  GeocodingResult({
    required this.latitude,
    required this.longitude,
    required this.displayName,
  });

  @override
  String toString() => displayName;
}

class GeocodingService {
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org/search';

  /// Obtiene sugerencias de direcciones mientras el usuario escribe
  static Future<List<GeocodingResult>> getSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse('$_nominatimUrl?q=$query&format=json&limit=5'),
        headers: {
          'User-Agent': 'sport_unity_app',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return [];
      }

      final results = jsonDecode(response.body) as List;
      return results
          .map((r) => GeocodingResult(
                latitude: double.parse(r['lat'].toString()),
                longitude: double.parse(r['lon'].toString()),
                displayName: r['display_name'] as String,
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Geocodifica una dirección y retorna coordenadas validadas
  /// Lanza una excepción si la dirección no existe
  static Future<GeocodingResult> geocodeAddress(String address) async {
    print('[GeocodingService] Geocodificando: $address');

    try {
      final response = await http.get(
        Uri.parse('$_nominatimUrl?q=$address&format=json&limit=1'),
        headers: {
          'User-Agent': 'sport_unity_app',
        },
      ).timeout(const Duration(seconds: 10));

      print('[GeocodingService] Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Error en geocodificación: ${response.statusCode}');
      }

      final results = jsonDecode(response.body) as List;

      if (results.isEmpty) {
        throw Exception('Dirección no encontrada: "$address"');
      }

      final firstResult = results.first;
      final lat = double.parse(firstResult['lat'].toString());
      final lon = double.parse(firstResult['lon'].toString());
      final displayName = firstResult['display_name'] as String;

      print('[GeocodingService] Encontrado: $displayName ($lat, $lon)');

      return GeocodingResult(
        latitude: lat,
        longitude: lon,
        displayName: displayName,
      );
    } catch (e) {
      print('[GeocodingService] Error: $e');
      rethrow;
    }
  }
}
