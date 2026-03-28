import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/storage_position.dart';
import '../../viewmodels/location_view_model.dart';
import 'location_form_screen.dart';
import 'location_inventory_screen.dart';
import 'position_form_screen.dart';

class LocationListScreen extends StatefulWidget {
  const LocationListScreen({super.key});

  @override
  State<LocationListScreen> createState() => _LocationListScreenState();
}

class _LocationListScreenState extends State<LocationListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationViewModel>().loadHierarchy();
    });
  }

  Future<void> _confirmDeleteLocation(String nome, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminare il luogo?'),
        content: Text(
          '«$nome» e tutte le sue posizioni verranno rimossi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      final err = await context.read<LocationViewModel>().deleteLocation(id);
      if (!mounted) return;
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }

  Future<void> _confirmDeletePosition(String nome, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminare la posizione?'),
        content: Text('«$nome» verrà rimossa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      final err = await context.read<LocationViewModel>().deletePosition(id);
      if (!mounted) return;
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LocationViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Luoghi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Aggiorna',
            onPressed: vm.isLoading ? null : () => vm.loadHierarchy(),
          ),
        ],
      ),
      body: _buildBody(context, vm),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey<String>('fab-location'),
        heroTag: 'fab-location',
        onPressed: () async {
          await Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => const LocationFormScreen(),
            ),
          );
          if (context.mounted) {
            await context.read<LocationViewModel>().loadHierarchy();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, LocationViewModel vm) {
    if (vm.isLoading && vm.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null && vm.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(vm.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => vm.loadHierarchy(),
                child: const Text('Riprova'),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.place_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nessun luogo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Tocca + per aggiungerne uno.'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => vm.loadHierarchy(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: vm.items.length,
        itemBuilder: (context, index) {
          final row = vm.items[index];
          final loc = row.location;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              key: ValueKey('loc-${loc.id}'),
              leading: const Icon(Icons.place_outlined),
              title: Row(
                children: [
                  Expanded(child: Text(loc.nome)),
                  IconButton(
                    icon: const Icon(Icons.inventory_2_outlined),
                    tooltip: 'Inventario in questo luogo',
                    onPressed: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              LocationInventoryScreen(locationId: loc.id),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Modifica luogo',
                    onPressed: () async {
                      await Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => LocationFormScreen(location: loc),
                        ),
                      );
                      if (context.mounted) {
                        await context.read<LocationViewModel>().loadHierarchy();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Elimina luogo',
                    onPressed: () => _confirmDeleteLocation(loc.nome, loc.id),
                  ),
                ],
              ),
              subtitle: loc.descrizione == null || loc.descrizione!.isEmpty
                  ? null
                  : Text(
                      loc.descrizione!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TextButton.icon(
                      onPressed: () async {
                        await Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => PositionFormScreen(
                              initialLocationId: loc.id,
                            ),
                          ),
                        );
                        if (context.mounted) {
                          await context
                              .read<LocationViewModel>()
                              .loadHierarchy();
                        }
                      },
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Aggiungi posizione'),
                    ),
                  ),
                ),
                ...row.positions.map(
                  (StoragePosition p) => ListTile(
                    key: ValueKey('pos-${p.id}'),
                    contentPadding: const EdgeInsets.only(left: 24, right: 8),
                    title: Text(p.nome),
                    subtitle: p.descrizione == null || p.descrizione!.isEmpty
                        ? null
                        : Text(p.descrizione!),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Modifica',
                          onPressed: () async {
                            await Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) => PositionFormScreen(
                                  position: p,
                                ),
                              ),
                            );
                            if (context.mounted) {
                              await context
                                  .read<LocationViewModel>()
                                  .loadHierarchy();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Elimina',
                          onPressed: () =>
                              _confirmDeletePosition(p.nome, p.id),
                        ),
                      ],
                    ),
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
