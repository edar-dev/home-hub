import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/location_with_positions.dart';
import '../../viewmodels/location_inventory_view_model.dart';
import '../../viewmodels/location_view_model.dart';
import '../widgets/product_card.dart';
import '../widgets/stitch_top_app_bar.dart';
import '../widgets/product_placement_helper.dart';
import 'location_form_screen.dart';
import 'position_form_screen.dart';
import 'product_form_screen.dart';

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
  Future<void> _refreshAll({bool refreshLocations = false}) async {
    if (!mounted) return;
    if (refreshLocations) {
      await context.read<LocationViewModel>().loadHierarchy();
      if (!mounted) return;
    }
    await context.read<LocationInventoryViewModel>().load();
    if (!mounted) return;
  }

  Future<void> _openCreateLocation() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const LocationFormScreen(),
      ),
    );
    await _refreshAll(refreshLocations: true);
  }

  Future<void> _openCreateProduct({String? initialPositionId}) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ProductFormScreen(initialPositionId: initialPositionId),
      ),
    );
    await _refreshAll();
  }

  Future<void> _openCreatePosition({String? initialLocationId}) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PositionFormScreen(initialLocationId: initialLocationId),
      ),
    );
    await _refreshAll(refreshLocations: true);
  }

  Future<void> _openQuickCreateMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add_box_outlined),
                title: const Text('Nuovo prodotto'),
                subtitle: const Text('Flusso rapido consigliato'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _openCreateProduct();
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_business_outlined),
                title: const Text('Nuovo luogo'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _openCreateLocation();
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_location_alt_outlined),
                title: const Text('Nuova posizione'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _openCreatePosition();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openSectionQuickAdd(LocationInventorySection section) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final hasPositions = section.blocks.isNotEmpty;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add_location_alt_outlined),
                title: const Text('Nuova posizione'),
                subtitle: Text('Nel luogo ${section.location.nome}'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _openCreatePosition(initialLocationId: section.location.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_box_outlined),
                title: const Text('Nuovo prodotto'),
                subtitle: Text(
                  hasPositions
                      ? 'Con posizione pre-selezionata'
                      : 'Prima crea una posizione in questo luogo',
                ),
                enabled: hasPositions,
                onTap: !hasPositions
                    ? null
                    : () {
                        Navigator.of(ctx).pop();
                        _openCreateProduct(
                          initialPositionId: section.blocks.first.position.id,
                        );
                      },
              ),
            ],
          ),
        );
      },
    );
  }

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
    final locItems = context.select<LocationViewModel, List<LocationWithPositions>>(
      (vm) => vm.items,
    );
    final locVm = context.read<LocationViewModel>();
    final placementIndex = buildPlacementIndex(locItems);

    final title = widget.locationId == null
        ? 'Riepilogo per stanza'
        : locVm.getLocationWithPositions(widget.locationId!)?.location.nome ??
            'Inventario luogo';

    return Scaffold(
      appBar: StitchTopAppBar(
        title: title,
        leading: widget.locationId == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Indietro',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Aggiorna',
            onPressed: inv.isLoading ? null : () => inv.load(),
          ),
        ],
      ),
      body: _buildBody(context, inv, placementIndex),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-overview-create',
        tooltip: 'Crea',
        onPressed: _openQuickCreateMenu,
        child: const Icon(Icons.add),
      ),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
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
              const Text('Crea il primo luogo per iniziare.'),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _openCreateLocation,
                icon: const Icon(Icons.add_business_outlined),
                label: const Text('Nuovo luogo'),
              ),
            ],
          ),
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
                trailing: PopupMenuButton<String>(
                  tooltip: 'Altre azioni',
                  onSelected: (v) {
                    if (v == 'position') {
                      _openCreatePosition(initialLocationId: section.location.id);
                    } else if (v == 'menu') {
                      _openSectionQuickAdd(section);
                    }
                  },
                  itemBuilder: (ctx) => const [
                    PopupMenuItem<String>(
                      value: 'position',
                      child: Text('Nuova posizione'),
                    ),
                    PopupMenuItem<String>(
                      value: 'menu',
                      child: Text('Altre opzioni...'),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        onPressed: section.blocks.isEmpty
                            ? () => _openCreatePosition(
                                  initialLocationId: section.location.id,
                                )
                            : () => _openCreateProduct(
                                  initialPositionId: section.blocks.first.position.id,
                                ),
                        icon: const Icon(Icons.add_box_outlined),
                        label: Text(
                          section.blocks.isEmpty
                              ? 'Crea posizione per aggiungere prodotti'
                              : 'Aggiungi prodotto',
                        ),
                      ),
                    ),
                  ),
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
