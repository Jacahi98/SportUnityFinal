import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/service_locator.dart';
import 'presentation/pages/auth_gate_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/viewmodels/activity_detail_viewmodel.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/create_activity_viewmodel.dart';
import 'presentation/viewmodels/home_viewmodel.dart';

class SportUnityApp extends StatelessWidget {
  const SportUnityApp({super.key});

  static final ServiceLocator _dependencies = ServiceLocator();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            _dependencies.isLoggedInUseCase,
            _dependencies.signInUseCase,
            _dependencies.signUpUseCase,
            _dependencies.signOutUseCase,
          )..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(_dependencies.getActivitiesUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CreateActivityViewModel(_dependencies.publishActivityUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ActivityDetailViewModel(_dependencies.deleteActivityUseCase),
        ),
      ],
      child: MaterialApp(
        title: 'Sport Unity',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routes: {'/home': (_) => const HomePage()},
        home: const AuthGatePage(),
      ),
    );
  }
}
