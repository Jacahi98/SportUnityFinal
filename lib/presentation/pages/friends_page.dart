import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/friends_viewmodel.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FriendsViewModel>().loadPendingRequests();
        context.read<FriendsViewModel>().loadFriends();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    final query = _searchController.text.trim();
    context.read<FriendsViewModel>().searchUsers(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Amigos')),
      body: Consumer<FriendsViewModel>(
        builder: (context, viewModel, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Buscador
                Text(
                  'Buscar usuario',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Busca por alias...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.search),
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: viewModel.isLoading ? null : _search,
                      child: const Text('Buscar'),
                    ),
                  ],
                ),
                if (viewModel.searchResults.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Resultados (${viewModel.searchResults.length})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...viewModel.searchResults.map((user) {
                    final userId = user['id'] as String;
                    final alias = user['alias'] as String?;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(alias ?? 'Sin alias'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            context.read<FriendsViewModel>().sendRequest(userId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Solicitud enviada'),
                              ),
                            );
                          },
                          child: const Text('Añadir'),
                        ),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 24),
                // Solicitudes recibidas
                Text(
                  'Solicitudes recibidas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (viewModel.pendingRequests.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('No tienes solicitudes pendientes'),
                  )
                else
                  ...viewModel.pendingRequests.map((request) {
                    final friendshipId = request['id'] as String;
                    final senderAlias = request['profiles']?['alias'] as String? ?? 'Sin alias';
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(senderAlias),
                        trailing: SizedBox(
                          width: 140,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () {
                                  context
                                      .read<FriendsViewModel>()
                                      .acceptRequest(friendshipId);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  context
                                      .read<FriendsViewModel>()
                                      .rejectRequest(friendshipId);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 24),
                // Mis amigos
                Text(
                  'Mis amigos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (viewModel.friends.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('No tienes amigos aún'),
                  )
                else
                  ...viewModel.friends.map((friend) {
                    final friendAlias = friend['alias'] as String? ?? 'Sin alias';
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(friendAlias),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
