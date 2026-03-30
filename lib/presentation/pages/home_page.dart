import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/activity_card.dart';
import 'activity_detail_page.dart';
import 'create_activity_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sport Unity'),
        actions: [
          IconButton(
            onPressed: () async {
              await context.read<AuthViewModel>().signOut();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, homeViewModel, _) {
          return Column(
            children: [
              SizedBox(
                height: 280,
                child: FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(40.4167, -3.70325),
                    initialZoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.sport_unity',
                    ),
                    MarkerLayer(
                      markers: homeViewModel.activities
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
                                      await homeViewModel.loadActivities();
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
              Expanded(
                child: homeViewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : homeViewModel.activities.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_off,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Todavía no hay actividades',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pulsa + para publicar una',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: homeViewModel.activities.length,
                            itemBuilder: (context, index) {
                              final activity = homeViewModel.activities[index];
                              return GestureDetector(
                                onTap: () async {
                                  final refreshed = await Navigator.of(context).push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) => ActivityDetailPage(activity: activity),
                                    ),
                                  );
                                  if (refreshed == true && mounted) {
                                    await homeViewModel.loadActivities();
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
          final homeViewModel = context.read<HomeViewModel>();
          final published = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const CreateActivityPage()),
          );
          if (published == true && mounted) {
            await homeViewModel.loadActivities();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
