<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/activity_card.dart';
import 'activity_detail_page.dart';
import 'create_activity_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const List<String> _sports = [
    'Fútbol', 'Baloncesto', 'Running', 'Tenis', 'Natación',
    'Ciclismo', 'Senderismo', 'Yoga', 'Boxeo', 'Voleibol',
    'Patinaje', 'Escalada', 'Fútbol Sala', 'Badminton', 'Golf',
  ];
  static const List<String> _levels = ['Principiante', 'Intermedio', 'Avanzado'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadActivities();
    });
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'fútbol':
      case 'fútbol sala':
        return Icons.sports_soccer;
      case 'baloncesto':
        return Icons.sports_basketball;
      case 'running':
        return Icons.directions_run;
      case 'tenis':
        return Icons.sports_tennis;
      case 'natación':
        return Icons.pool;
      case 'ciclismo':
        return Icons.directions_bike;
      case 'senderismo':
        return Icons.hiking;
      case 'yoga':
        return Icons.self_improvement;
      case 'boxeo':
        return Icons.sports_kabaddi;
      case 'voleibol':
        return Icons.sports_volleyball;
      case 'patinaje':
        return Icons.skateboarding;
      case 'escalada':
        return Icons.terrain;
      case 'badminton':
        return Icons.sports_handball;
      case 'golf':
        return Icons.golf_course;
      default:
        return Icons.sports;
    }
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ProfileViewModel(),
          child: const ProfilePage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sport Unity'),
        actions: [
          IconButton(
            onPressed: () => _openProfile(context),
            icon: const Icon(Icons.person),
            tooltip: 'Mi perfil',
          ),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, vm, _) {
          return Column(
            children: [
              // Filtros
              _FilterBar(sports: _sports, levels: _levels, vm: vm),
              // Mapa
              SizedBox(
                height: 260,
                child: FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(40.4167, -3.70325),
                    initialZoom: 6,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.sport_unity',
                    ),
                    MarkerLayer(
                      markers: vm.activities
                          .map((activity) => Marker(
                                point: LatLng(activity.latitude, activity.longitude),
                                width: 45,
                                height: 45,
                                child: GestureDetector(
                                  onTap: () async {
                                    final refreshed = await Navigator.of(context).push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) => ActivityDetailPage(activity: activity),
                                      ),
                                    );
                                    if (refreshed == true && mounted) {
                                      await vm.loadActivities();
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _getSportIcon(activity.sport),
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              // Lista
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.activities.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_off, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay actividades con estos filtros',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Prueba a cambiar los filtros o crea una nueva',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: vm.activities.length,
                            itemBuilder: (context, index) {
                              final activity = vm.activities[index];
                              return GestureDetector(
                                onTap: () async {
                                  final refreshed = await Navigator.of(context).push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) => ActivityDetailPage(activity: activity),
                                    ),
                                  );
                                  if (refreshed == true && mounted) {
                                    await vm.loadActivities();
                                  }
                                },
                                child: ActivityCard(activity: activity),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final vm = context.read<HomeViewModel>();
          final published = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const CreateActivityPage()),
          );
          if (published == true && mounted) {
            await vm.loadActivities();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.sports, required this.levels, required this.vm});

  final List<String> sports;
  final List<String> levels;
  final HomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          // Filtros de tiempo
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final filter in [('1h', '1h'), ('24h', '24h'), ('7d', '7d'), ('all', 'Todo')])
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(filter.$2),
                      selected: vm.timeFilter == filter.$1,
                      onSelected: (_) => vm.setTimeFilter(filter.$1),
                    ),
                  ),
                const SizedBox(width: 8),
                // Filtro deporte
                _DropdownFilter(
                  icon: Icons.sports,
                  hint: 'Deporte',
                  value: vm.sportFilter,
                  items: sports,
                  onChanged: vm.setSportFilter,
                ),
                const SizedBox(width: 8),
                // Filtro nivel
                _DropdownFilter(
                  icon: Icons.bar_chart,
                  hint: 'Nivel',
                  value: vm.levelFilter,
                  items: levels,
                  onChanged: vm.setLevelFilter,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  const _DropdownFilter({
    required this.icon,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final IconData icon;
  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: value != null ? Theme.of(context).colorScheme.primary : Colors.grey.shade400),
        borderRadius: BorderRadius.circular(20),
        color: value != null ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : null,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(hint, style: const TextStyle(fontSize: 13)),
            ],
          ),
          items: [
            DropdownMenuItem(value: null, child: Text('Todos los $hint'.toLowerCase())),
            ...items.map((s) => DropdownMenuItem(value: s, child: Text(s))),
          ],
          onChanged: onChanged,
          isDense: true,
          style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }
}
=======
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../viewmodels/friends_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../widgets/activity_card.dart';
import 'activity_detail_page.dart';
import 'create_activity_page.dart';
import 'friends_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const List<String> _sports = [
    'Fútbol', 'Baloncesto', 'Running', 'Tenis', 'Natación',
    'Ciclismo', 'Senderismo', 'Yoga', 'Boxeo', 'Voleibol',
    'Patinaje', 'Escalada', 'Fútbol Sala', 'Badminton', 'Golf',
  ];
  static const List<String> _levels = ['Principiante', 'Intermedio', 'Avanzado'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadActivities();
      _showWelcomeDialog();
    });
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bienvenido a Sport Unity'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Esta es una comunidad inclusiva y respetuosa donde puedes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('• Compartir actividades deportivas con otras personas'),
              Text('• Conocer gente nueva y hacer amigos'),
              Text('• Practicar deporte en un entorno seguro y acogedor'),
              SizedBox(height: 12),
              Text(
                'Recuerda siempre ser respetuoso con los demás y valorar la diversidad.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'fútbol':
      case 'fútbol sala':
        return Icons.sports_soccer;
      case 'baloncesto':
        return Icons.sports_basketball;
      case 'running':
        return Icons.directions_run;
      case 'tenis':
        return Icons.sports_tennis;
      case 'natación':
        return Icons.pool;
      case 'ciclismo':
        return Icons.directions_bike;
      case 'senderismo':
        return Icons.hiking;
      case 'yoga':
        return Icons.self_improvement;
      case 'boxeo':
        return Icons.sports_kabaddi;
      case 'voleibol':
        return Icons.sports_volleyball;
      case 'patinaje':
        return Icons.skateboarding;
      case 'escalada':
        return Icons.terrain;
      case 'badminton':
        return Icons.sports_handball;
      case 'golf':
        return Icons.golf_course;
      default:
        return Icons.sports;
    }
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ProfileViewModel(),
          child: const ProfilePage(),
        ),
      ),
    );
  }

  void _openFriends(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => FriendsViewModel(),
          child: const FriendsPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sport Unity'),
        actions: [
          IconButton(
            onPressed: () => _openFriends(context),
            icon: const Icon(Icons.people),
            tooltip: 'Amigos',
          ),
          IconButton(
            onPressed: () => _openProfile(context),
            icon: const Icon(Icons.person),
            tooltip: 'Mi perfil',
          ),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, vm, _) {
          return Column(
            children: [
              // Filtros
              _FilterBar(sports: _sports, levels: _levels, vm: vm),
              // Mapa (70% de la pantalla)
              Expanded(
                flex: 70,
                child: FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(40.4167, -3.70325),
                    initialZoom: 6,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.sport_unity',
                    ),
                    MarkerLayer(
                      markers: vm.activities
                          .map((activity) => Marker(
                                point: LatLng(activity.latitude, activity.longitude),
                                width: 45,
                                height: 45,
                                child: GestureDetector(
                                  onTap: () async {
                                    final refreshed = await Navigator.of(context).push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) => ActivityDetailPage(activity: activity),
                                      ),
                                    );
                                    if (refreshed == true && mounted) {
                                      await vm.loadActivities();
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _getSportIcon(activity.sport),
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              // Lista (30% de la pantalla)
              Expanded(
                flex: 30,
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.activities.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_off, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay actividades con estos filtros',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Prueba a cambiar los filtros o crea una nueva',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: vm.activities.length,
                            itemBuilder: (context, index) {
                              final activity = vm.activities[index];
                              return GestureDetector(
                                onTap: () async {
                                  final refreshed = await Navigator.of(context).push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) => ActivityDetailPage(activity: activity),
                                    ),
                                  );
                                  if (refreshed == true && mounted) {
                                    await vm.loadActivities();
                                  }
                                },
                                child: ActivityCard(activity: activity),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final vm = context.read<HomeViewModel>();
          final published = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const CreateActivityPage()),
          );
          if (published == true && mounted) {
            await vm.loadActivities();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.sports, required this.levels, required this.vm});

  final List<String> sports;
  final List<String> levels;
  final HomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final filter in [('1h', '1h'), ('24h', '24h'), ('7d', '7d'), ('all', 'Todo')])
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(filter.$2),
                  selected: vm.timeFilter == filter.$1,
                  onSelected: (_) => vm.setTimeFilter(filter.$1),
                ),
              ),
            const SizedBox(width: 8),
            // Filtro deporte
            _DropdownFilter(
              icon: Icons.sports,
              hint: 'Deporte',
              value: vm.sportFilter,
              items: sports,
              onChanged: vm.setSportFilter,
            ),
            const SizedBox(width: 8),
            // Filtro nivel
            _DropdownFilter(
              icon: Icons.bar_chart,
              hint: 'Nivel',
              value: vm.levelFilter,
              items: levels,
              onChanged: vm.setLevelFilter,
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  const _DropdownFilter({
    required this.icon,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final IconData icon;
  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: value != null ? Theme.of(context).colorScheme.primary : Colors.grey.shade400),
        borderRadius: BorderRadius.circular(20),
        color: value != null ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : null,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(hint, style: const TextStyle(fontSize: 13)),
            ],
          ),
          items: [
            DropdownMenuItem(value: null, child: Text('Todos los $hint'.toLowerCase())),
            ...items.map((s) => DropdownMenuItem(value: s, child: Text(s))),
          ],
          onChanged: onChanged,
          isDense: true,
          style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }
}
>>>>>>> jacahi
