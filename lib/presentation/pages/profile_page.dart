import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _aliasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<ProfileViewModel>();
      await vm.loadProfile();
      if (mounted && vm.alias != null) {
        _aliasController.text = vm.alias!;
      }
    });
  }

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Consumer<ProfileViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Avatar por defecto
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 32),
                // Alias
                TextField(
                  controller: _aliasController,
                  decoration: InputDecoration(
                    labelText: 'Alias',
                    hintText: 'Tu nombre de usuario',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 24),
                // Error / éxito
                if (vm.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)),
                  ),
                if (vm.successMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(vm.successMessage!, style: const TextStyle(color: Colors.green)),
                  ),
                // Guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: vm.isSaving
                        ? null
                        : () async {
                            final alias = _aliasController.text.trim();
                            if (alias.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('El alias no puede estar vacío')),
                              );
                              return;
                            }
                            await vm.saveProfile(alias: alias);
                          },
                    icon: vm.isSaving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save),
                    label: Text(vm.isSaving ? 'Guardando...' : 'Guardar cambios'),
                  ),
                ),
                const SizedBox(height: 12),
                // Cerrar sesión
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
<<<<<<< HEAD
                      await context.read<AuthViewModel>().signOut();
=======
                      final authVM = context.read<AuthViewModel>();
                      final nav = Navigator.of(context);
                      await authVM.signOut();
                      authVM.init();
                      if (mounted) {
                        nav.popUntil((route) => route.isFirst);
                      }
>>>>>>> jacahi
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
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
