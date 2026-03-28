import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/location_inventory_view_model.dart';
import '../../viewmodels/location_view_model.dart';
import '../widgets/product_card.dart';
import '../widgets/product_placement_helper.dart';

/// Riepilogo inventario per luogo e posizione (FASE 3).
class LocationInventoryScreen extends StatefulWidget {
  const LocationInventoryScreen({super.key, this.locationId});

  /// Se valorizzato, mostra solo questo luogo.
  final String? locationId;

  @override
  State<LocationInventoryScreen> createState() =>
      _LocationInventoryScreenState();
}

class _LocationInventoryScreenState extends State<LocationInventoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final inv = context.read<LocationInventoryViewModel>();
      inv.setLocationFilter(widget.locationId);
      await inv.load();
    });
  }

  @override
  void didUpdateWidget(covariant LocationInventoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locationId != widget.locationId) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final inv = context.read<LocationInventoryViewModel>();
        inv.setLocationFilter(widget.locationId);
        await inv.load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inv = context.watch<LocationInventoryViewModel>();
    final locVm = context.watch<LocationViewModel>();
    final placementIndex = buildPlacementIndex(locVm.items);

    final title = widget.locationId == null
        ? 'Riepilogo per stanza'
        : locVm.getLocationWithPositions(widget.locationId!)?.location.nome ??
            'Inventario luogo';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Aggiorna',
            onPressed: inv.isLoading ? null : () => inv.load(),
          ),
        ],
      ),
      body: _buildBody(context, inv, placementIndex),
    );
  }

  Widget _buildBody(
    BuildContext context,
    LocationInventoryViewModel inv,
    Map<String, (String, String)> placementIndex,
  ) {
    if (inv.isLoading && inv.sections.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (inv.errorMessage != null && inv.sections.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(inv.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => inv.load(),
                child: const Text('Riprova'),
              ),
            ],
          ),
        ),
      );
    }
    if (inv.sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_work_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nessun luogo definito',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Aggiungi luoghi nella scheda Luoghi.'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => inv.load(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: inv.sections.length,
        itemBuilder: (context, si) {
          final section = inv.sections[si];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                key: ValueKey('loc-inv-${section.location.id}'),
                leading: const Icon(Icons.place_outlined),
                title: Text(section.location.nome),
                subtitle: Text(
                  '${section.productCount} prodotti · '
                  '${section.blocks.length} posizioni',
                ),
                children: [
                  if (section.blocks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Nessuna posizione in questo luogo.'),
                    )
                  else
                    ...section.blocks.map((block) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                            child: Text(
                              block.position.nome,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (block.products.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 8,
                              ),
                              child: Text(
                                'Nessun prodotto',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            )
                          else
                            ...block.products.map(
                              (p) => Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  bottom: 8,
                                ),
                                child: ProductCard(
                                  product: p,
                                  placementLine: placementLineForProduct(
                                    p,
                                    placementIndex,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
