import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_unity/services/supabase_service.dart';
import 'package:sport_unity/screens/add_activity_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final supabaseService = SupabaseService();
  final mapController = MapController();
  List<Map<String, dynamic>> actividades = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActividades();
  }

  void _loadActividades() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await supabaseService.getActividades();
      setState(() {
        actividades = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _logout() async {
    await supabaseService.signOut();
  }

  void _navigateToAddActivity() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddActivityScreen()),
    );
    if (result == true) {
      _loadActividades();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Actividades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: const LatLng(40.4637, -3.7492),
                initialZoom: 6.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.sport_unity',
                ),
                MarkerLayer(
                  markers: actividades
                      .map(
                        (actividad) => Marker(
                          point: LatLng(
                            actividad['latitud'] as double,
                            actividad['longitud'] as double,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              _showActivityDetails(actividad);
                            },
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddActivity,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showActivityDetails(Map<String, dynamic> actividad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(actividad['titulo'] ?? 'Actividad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deporte: ${actividad['deporte'] ?? 'N/A'}'),
            Text('Descripción: ${actividad['descripcion'] ?? 'N/A'}'),
            Text('Fecha: ${actividad['fecha'] ?? 'N/A'}'),
            Text('Hora: ${actividad['hora'] ?? 'N/A'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
