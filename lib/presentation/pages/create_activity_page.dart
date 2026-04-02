<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/services/geocoding_service.dart';
import '../viewmodels/create_activity_viewmodel.dart';

class CreateActivityPage extends StatefulWidget {
  const CreateActivityPage({super.key});

  @override
  State<CreateActivityPage> createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _imagePicker = ImagePicker();

  final List<String> _sports = [
    'Fútbol',
    'Baloncesto',
    'Running',
    'Tenis',
    'Natación',
    'Ciclismo',
    'Senderismo',
    'Yoga',
    'Boxeo',
    'Voleibol',
    'Patinaje',
    'Escalada',
    'Fútbol Sala',
    'Badminton',
    'Golf',
  ];
  final List<String> _levels = ['Principiante', 'Intermedio', 'Avanzado'];

  String? _selectedSport;
  String? _selectedLevel;
  XFile? _selectedImage;
  DateTime? _selectedDateTime;
  double? _validatedLatitude;
  double? _validatedLongitude;
  String? _validatedLocation;
  String? _selectedCity;
  bool _isValidatingLocation = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1200,
      );
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _publish() async {
    // Validar título
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un título para la actividad')),
      );
      return;
    }

    // Validar deporte y nivel
    if (_selectedSport == null || _selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona deporte y nivel')),
      );
      return;
    }

    // Validar descripción
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Describe la actividad')),
      );
      return;
    }

    // Validar que haya una ciudad seleccionada
    if (_cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una ciudad')),
      );
      return;
    }

    // Validar que haya una dirección seleccionada
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una dirección')),
      );
      return;
    }

    // Si no se validó la ubicación manualmente, intenta geocodificar
    if (_validatedLatitude == null || _validatedLongitude == null) {
      setState(() => _isValidatingLocation = true);

      try {
        final fullAddress = '${_addressController.text.trim()}, ${_cityController.text.trim()}';
        final geocodingResult = await GeocodingService.geocodeAddress(fullAddress);
        _validatedLatitude = geocodingResult.latitude;
        _validatedLongitude = geocodingResult.longitude;
        _validatedLocation = geocodingResult.displayName;

        if (!mounted) return;
        setState(() => _isValidatingLocation = false);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isValidatingLocation = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dirección no válida: ${_addressController.text}, ${_cityController.text}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final viewModel = context.read<CreateActivityViewModel>();

    final success = await viewModel.publishActivity(
      sport: _selectedSport!,
      level: _selectedLevel!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      imageFile: _selectedImage,
      dateTime: _selectedDateTime ?? DateTime.now(),
      location: _validatedLocation ?? '${_addressController.text.trim()}, ${_cityController.text.trim()}',
      latitude: _validatedLatitude ?? 40.4167,
      longitude: _validatedLongitude ?? -3.70325,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Actividad publicada!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Error al publicar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva actividad')),
      body: Consumer<CreateActivityViewModel>(
        builder: (context, viewModel, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: 'Ej: Fútbol en el parque',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                // Deporte
                DropdownButtonFormField<String>(
                  initialValue: _selectedSport,
                  decoration: const InputDecoration(labelText: 'Deporte'),
                  items: _sports
                      .map((sport) => DropdownMenuItem(
                            value: sport,
                            child: Text(sport),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedSport = value),
                ),
                const SizedBox(height: 12),
                // Nivel
                DropdownButtonFormField<String>(
                  initialValue: _selectedLevel,
                  decoration: const InputDecoration(labelText: 'Nivel'),
                  items: _levels
                      .map((level) => DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedLevel = value),
                ),
                const SizedBox(height: 12),
                // Descripción
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                // Fecha
                ListTile(
                  title: Text(_selectedDateTime == null
                      ? 'Fecha: Ahora (${DateTime.now().toString().split('.')[0]})'
                      : 'Fecha: ${_selectedDateTime.toString().split('.')[0]}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDateTime,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 12),
                // Ciudad con Autocomplete
                TypeAheadField<GeocodingResult>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'Ciudad',
                      hintText: 'Ej: Madrid, Barcelona, Palencia...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.location_city),
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    if (pattern.isEmpty) return [];
                    return await GeocodingService.getSuggestions(pattern);
                  },
                  itemBuilder: (context, GeocodingResult suggestion) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(suggestion.displayName),
                    );
                  },
                  onSuggestionSelected: (GeocodingResult suggestion) {
                    setState(() {
                      _cityController.text = suggestion.displayName;
                      _selectedCity = suggestion.displayName;
                      _addressController.clear();
                      _validatedLatitude = null;
                      _validatedLongitude = null;
                      _validatedLocation = null;
                    });
                  },
                  noItemsFoundBuilder: (context) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'No se encontraron ciudades',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  },
                  loadingBuilder: (context) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                        ),
                      ),
                    );
                  },
                  debounceDuration: const Duration(milliseconds: 400),
                  hideOnEmpty: true,
                  hideOnLoading: false,
                  autoFlipDirection: true,
                ),
                const SizedBox(height: 12),
                // Dirección con Autocomplete (solo visible si se selecciona ciudad)
                if (_selectedCity != null && _selectedCity!.isNotEmpty)
                  TypeAheadField<GeocodingResult>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Dirección',
                        hintText: 'Ej: Calle Mayor 10, Plaza Central...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      if (pattern.isEmpty) return [];
                      final query = '$pattern, $_selectedCity';
                      return await GeocodingService.getSuggestions(query);
                    },
                    itemBuilder: (context, GeocodingResult suggestion) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(suggestion.displayName),
                      );
                    },
                    onSuggestionSelected: (GeocodingResult suggestion) {
                      setState(() {
                        _addressController.text = suggestion.displayName;
                        _validatedLatitude = suggestion.latitude;
                        _validatedLongitude = suggestion.longitude;
                        _validatedLocation = suggestion.displayName;
                      });
                    },
                    noItemsFoundBuilder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'No se encontraron direcciones',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                    loadingBuilder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                          ),
                        ),
                      );
                    },
                    debounceDuration: const Duration(milliseconds: 400),
                    hideOnEmpty: true,
                    hideOnLoading: false,
                    autoFlipDirection: true,
                  ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: Text(
                    _selectedImage != null
                        ? 'Foto seleccionada ✓'
                        : 'Seleccionar foto',
                  ),
                ),
                if (_selectedImage != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Text('✓ Imagen seleccionada'),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (viewModel.isSubmitting || _isValidatingLocation) ? null : _publish,
                    child: (viewModel.isSubmitting || _isValidatingLocation)
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Publicar actividad'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
=======
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/services/geocoding_service.dart';
import '../viewmodels/create_activity_viewmodel.dart';

class CreateActivityPage extends StatefulWidget {
  const CreateActivityPage({super.key});

  @override
  State<CreateActivityPage> createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _imagePicker = ImagePicker();

  final List<String> _sports = [
    'Fútbol',
    'Baloncesto',
    'Running',
    'Tenis',
    'Natación',
    'Ciclismo',
    'Senderismo',
    'Yoga',
    'Boxeo',
    'Voleibol',
    'Patinaje',
    'Escalada',
    'Fútbol Sala',
    'Badminton',
    'Golf',
  ];
  final List<String> _levels = ['Principiante', 'Intermedio', 'Avanzado'];
  final List<String> _inclusionTags = [
    'LGTBI+ friendly',
    'Para mayores (60+)',
    'Accesible',
    'Familiar',
    'Mixto',
  ];

  String? _selectedSport;
  String? _selectedLevel;
  XFile? _selectedImage;
  DateTime? _selectedDateTime;
  double? _validatedLatitude;
  double? _validatedLongitude;
  String? _validatedLocation;
  String? _selectedCity;
  bool _isValidatingLocation = false;
  final List<String> _selectedTags = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1200,
      );
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _publish() async {
    // Validar título
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un título para la actividad')),
      );
      return;
    }

    // Validar deporte y nivel
    if (_selectedSport == null || _selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona deporte y nivel')),
      );
      return;
    }

    // Validar descripción
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Describe la actividad')),
      );
      return;
    }

    // Validar que haya una ciudad seleccionada
    if (_cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una ciudad')),
      );
      return;
    }

    // Validar que haya una dirección seleccionada
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una dirección')),
      );
      return;
    }

    // Si no se validó la ubicación manualmente, intenta geocodificar
    if (_validatedLatitude == null || _validatedLongitude == null) {
      setState(() => _isValidatingLocation = true);

      try {
        final fullAddress = '${_addressController.text.trim()}, ${_cityController.text.trim()}';
        final geocodingResult = await GeocodingService.geocodeAddress(fullAddress);
        _validatedLatitude = geocodingResult.latitude;
        _validatedLongitude = geocodingResult.longitude;
        _validatedLocation = geocodingResult.displayName;

        if (!mounted) return;
        setState(() => _isValidatingLocation = false);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isValidatingLocation = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dirección no válida: ${_addressController.text}, ${_cityController.text}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final viewModel = context.read<CreateActivityViewModel>();

    final success = await viewModel.publishActivity(
      sport: _selectedSport!,
      level: _selectedLevel!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      imageFile: _selectedImage,
      dateTime: _selectedDateTime ?? DateTime.now(),
      location: _validatedLocation ?? '${_addressController.text.trim()}, ${_cityController.text.trim()}',
      latitude: _validatedLatitude ?? 40.4167,
      longitude: _validatedLongitude ?? -3.70325,
      tags: _selectedTags,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Actividad publicada!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Error al publicar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva actividad')),
      body: Consumer<CreateActivityViewModel>(
        builder: (context, viewModel, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: 'Ej: Fútbol en el parque',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                // Deporte
                DropdownButtonFormField<String>(
                  initialValue: _selectedSport,
                  decoration: const InputDecoration(labelText: 'Deporte'),
                  items: _sports
                      .map((sport) => DropdownMenuItem(
                            value: sport,
                            child: Text(sport),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedSport = value),
                ),
                const SizedBox(height: 12),
                // Nivel
                DropdownButtonFormField<String>(
                  initialValue: _selectedLevel,
                  decoration: const InputDecoration(labelText: 'Nivel'),
                  items: _levels
                      .map((level) => DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedLevel = value),
                ),
                const SizedBox(height: 12),
                // Descripción
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                // Fecha
                ListTile(
                  title: Text(_selectedDateTime == null
                      ? 'Fecha: Ahora (${DateTime.now().toString().split('.')[0]})'
                      : 'Fecha: ${_selectedDateTime.toString().split('.')[0]}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDateTime,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 12),
                // Ciudad con Autocomplete
                TypeAheadField<GeocodingResult>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'Ciudad',
                      hintText: 'Ej: Madrid, Barcelona, Palencia...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.location_city),
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    if (pattern.isEmpty) return [];
                    return await GeocodingService.getSuggestions(pattern);
                  },
                  itemBuilder: (context, GeocodingResult suggestion) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(suggestion.displayName),
                    );
                  },
                  onSuggestionSelected: (GeocodingResult suggestion) {
                    setState(() {
                      _cityController.text = suggestion.displayName;
                      _selectedCity = suggestion.displayName;
                      _addressController.clear();
                      _validatedLatitude = null;
                      _validatedLongitude = null;
                      _validatedLocation = null;
                    });
                  },
                  noItemsFoundBuilder: (context) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'No se encontraron ciudades',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  },
                  loadingBuilder: (context) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                        ),
                      ),
                    );
                  },
                  debounceDuration: const Duration(milliseconds: 400),
                  hideOnEmpty: true,
                  hideOnLoading: false,
                  autoFlipDirection: true,
                ),
                const SizedBox(height: 12),
                // Dirección con Autocomplete (solo visible si se selecciona ciudad)
                if (_selectedCity != null && _selectedCity!.isNotEmpty)
                  TypeAheadField<GeocodingResult>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Dirección',
                        hintText: 'Ej: Calle Mayor 10, Plaza Central...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      if (pattern.isEmpty) return [];
                      final query = '$pattern, $_selectedCity';
                      return await GeocodingService.getSuggestions(query);
                    },
                    itemBuilder: (context, GeocodingResult suggestion) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(suggestion.displayName),
                      );
                    },
                    onSuggestionSelected: (GeocodingResult suggestion) {
                      setState(() {
                        _addressController.text = suggestion.displayName;
                        _validatedLatitude = suggestion.latitude;
                        _validatedLongitude = suggestion.longitude;
                        _validatedLocation = suggestion.displayName;
                      });
                    },
                    noItemsFoundBuilder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'No se encontraron direcciones',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                    loadingBuilder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                          ),
                        ),
                      );
                    },
                    debounceDuration: const Duration(milliseconds: 400),
                    hideOnEmpty: true,
                    hideOnLoading: false,
                    autoFlipDirection: true,
                  ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: Text(
                    _selectedImage != null
                        ? 'Foto seleccionada ✓'
                        : 'Seleccionar foto',
                  ),
                ),
                if (_selectedImage != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Text('✓ Imagen seleccionada'),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  'Etiquetas de inclusión (opcional)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _inclusionTags
                      .map((tag) => FilterChip(
                            label: Text(tag),
                            selected: _selectedTags.contains(tag),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedTags.add(tag);
                                } else {
                                  _selectedTags.remove(tag);
                                }
                              });
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (viewModel.isSubmitting || _isValidatingLocation) ? null : _publish,
                    child: (viewModel.isSubmitting || _isValidatingLocation)
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Publicar actividad'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
>>>>>>> jacahi
