import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:sport_unity/services/supabase_service.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({Key? key}) : super(key: key);

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final supabaseService = SupabaseService();

  String? selectedDeporte;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  LatLng? selectedLocation;

  final deportes = ['Fútbol', 'Baloncesto', 'Tenis', 'Ciclismo', 'Senderismo'];

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030, 12, 31),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _selectLocation() async {
    final location = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );
    if (location != null) {
      setState(() {
        selectedLocation = location;
      });
    }
  }

  void _saveActivity() async {
    if (titleController.text.isEmpty ||
        selectedDeporte == null ||
        selectedDate == null ||
        selectedTime == null ||
        selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    try {
      await supabaseService.insertActividad(
        titulo: titleController.text,
        deporte: selectedDeporte!,
        descripcion: descriptionController.text,
        fecha: DateFormat('yyyy-MM-dd').format(selectedDate!),
        hora: '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
        latitud: selectedLocation!.latitude,
        longitud: selectedLocation!.longitude,
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Actividad')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              value: selectedDeporte,
              decoration: const InputDecoration(
                labelText: 'Deporte',
                border: OutlineInputBorder(),
              ),
              items: deportes
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedDeporte = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectDate,
              child: Text(selectedDate == null
                  ? 'Seleccionar Fecha'
                  : DateFormat('dd/MM/yyyy').format(selectedDate!)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectTime,
              child: Text(selectedTime == null
                  ? 'Seleccionar Hora'
                  : selectedTime!.format(context)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectLocation,
              child: Text(selectedLocation == null
                  ? 'Seleccionar Ubicación en Mapa'
                  : 'Ubicación: ${selectedLocation!.latitude.toStringAsFixed(4)}, ${selectedLocation!.longitude.toStringAsFixed(4)}'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveActivity,
              child: const Text('Guardar Actividad'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({Key? key}) : super(key: key);

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final mapController = MapController();
  LatLng? selectedPoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona Ubicación'),
        actions: [
          if (selectedPoint != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context, selectedPoint);
              },
            ),
        ],
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: const LatLng(40.4637, -3.7492),
          initialZoom: 6.0,
          onTap: (tapPosition, point) {
            setState(() {
              selectedPoint = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.sport_unity',
          ),
          if (selectedPoint != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: selectedPoint!,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
