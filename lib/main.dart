import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_unity/screens/login_screen.dart';
import 'package:sport_unity/screens/map_screen.dart';

const String supabaseUrl = 'https://msrpnpvlllljkxrywbsy.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1zcnBucHZsbGxsamt4cnl3YnN5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM2NzcwNjIsImV4cCI6MjA4OTI1MzA2Mn0.q0i8O7Li1McNRM5WYLfVNuRGdbikMlhnpdkXXhd-wpI';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportUnity',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const AuthChecker(),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      return const MapScreen();
    } else {
      return const LoginScreen();
    }
  }
}
