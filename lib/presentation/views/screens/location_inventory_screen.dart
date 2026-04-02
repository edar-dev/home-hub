import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/location_with_positions.dart';
import '../../mixins/deferred_shell_tab_load_mixin.dart';
import '../../viewmodels/home_shell_tab_controller.dart';
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

class _LocationInventoryScreenState extends State<LocationInventoryScreen>
    with DeferredShellTabLoadMixin {
  late final TextEditingController _searchCtrl;
  Timer? _searchDebounce;

  static const Duration _searchDebounceDuration = Duration(milliseconds: 250);

  void _onSearchTextChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      if (!mounted) return;
      context.read<LocationInventoryViewModel>().setSearchQuery(value);
    });
  }

  void _cancelSearchDebounce() => _searchDebounce?.cancel();

  @override
  int get deferredShellTabIndex => HomeShellTabController.tabOverview;

  @override
  void onDeferredShellTabVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final inv = context.read<LocationInventoryViewModel>();
      inv.setLocationFilter(widget.locationId);
      _searchCtrl.text = inv.searchQuery;
      await inv.load();
    });
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

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
        builder: (_) =>
            PositionFormScreen(initialLocationId: initialLocationId),
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
    final locItems =
        context.select<LocationViewModel, List<LocationWithPositions>>(
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
      if (inv.hasActiveProductFilters && inv.productsInScopeBeforeFilters > 0) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.filter_alt_off_outlined,
                  size: 56,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 12),
                Text(
                  'Nessun risultato con i filtri correnti',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text('Prova ad allargare i filtri o reimpostarli.'),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () {
                    _cancelSearchDebounce();
                    inv.clearProductFilters();
                    _searchCtrl.clear();
                  },
                  child: const Text('Reset filtri'),
                ),
              ],
            ),
          ),
        );
      }
      if (inv.hasLocationsInScope) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: ListView(
            children: [
              _FiltersSection(
                searchController: _searchCtrl,
                statusFilter: inv.statusFilter,
                openStateFilter: inv.openStateFilter,
                hasActiveFilters: inv.hasActiveProductFilters,
                onSearchChanged: inv.setSearchQuery,
                onStatusChanged: inv.setStatusFilter,
                onOpenStateChanged: inv.setOpenStateFilter,
                onReset: () {
                  inv.clearProductFilters();
                  _searchCtrl.clear();
                },
              ),
              const SizedBox(height: 24),
              const Center(child: Text('Nessun prodotto nelle posizioni.')),
            ],
          ),
        );
      }
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
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _FiltersSection(
            searchController: _searchCtrl,
            statusFilter: inv.statusFilter,
            openStateFilter: inv.openStateFilter,
            hasActiveFilters: inv.hasActiveProductFilters,
            onSearchChanged: _onSearchTextChanged,
            onStatusChanged: inv.setStatusFilter,
            onOpenStateChanged: inv.setOpenStateFilter,
            onReset: () {
              _cancelSearchDebounce();
              inv.clearProductFilters();
              _searchCtrl.clear();
            },
          ),
          const SizedBox(height: 12),
          ...List.generate(inv.sections.length, (si) {
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
                        _openCreatePosition(
                            initialLocationId: section.location.id);
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
                                    initialPositionId:
                                        section.blocks.first.position.id,
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
          }),
        ],
      ),
    );
  }
}

class _FiltersSection extends StatefulWidget {
  const _FiltersSection({
    required this.searchController,
    required this.statusFilter,
    required this.openStateFilter,
    required this.hasActiveFilters,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onOpenStateChanged,
    required this.onReset,
  });

  final TextEditingController searchController;
  final ProductStatusFilter statusFilter;
  final ProductOpenStateFilter openStateFilter;
  final bool hasActiveFilters;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ProductStatusFilter> onStatusChanged;
  final ValueChanged<ProductOpenStateFilter> onOpenStateChanged;
  final VoidCallback onReset;

  @override
  State<_FiltersSection> createState() => _FiltersSectionState();
}

class _FiltersSectionState extends State<_FiltersSection> {
  bool _advancedOpen = false;

  bool get _advancedActive =>
      widget.statusFilter != ProductStatusFilter.all ||
      widget.openStateFilter != ProductOpenStateFilter.all;

  String _advancedSummary() {
    final parts = <String>[];
    switch (widget.statusFilter) {
      case ProductStatusFilter.all:
        break;
      case ProductStatusFilter.expiring:
        parts.add('In scadenza');
        break;
      case ProductStatusFilter.expired:
        parts.add('Scaduti');
        break;
      case ProductStatusFilter.lowStock:
        parts.add('Low stock');
        break;
    }
    switch (widget.openStateFilter) {
      case ProductOpenStateFilter.all:
        break;
      case ProductOpenStateFilter.opened:
        parts.add('Aperti');
        break;
      case ProductOpenStateFilter.unopened:
        parts.add('Non aperti');
        break;
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final summary = _advancedSummary();
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: widget.searchController,
              onChanged: widget.onSearchChanged,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cerca prodotto',
                isDense: true,
              ),
            ),
            const SizedBox(height: 4),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _advancedOpen = !_advancedOpen),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tune_outlined,
                        size: 22,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filtri avanzati',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            if (!_advancedOpen && summary.isNotEmpty)
                              Text(
                                summary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                              ),
                          ],
                        ),
                      ),
                      if (widget.hasActiveFilters)
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          tooltip: 'Reset filtri',
                          visualDensity: VisualDensity.compact,
                          onPressed: widget.onReset,
                        ),
                      Icon(
                        _advancedOpen ? Icons.expand_less : Icons.expand_more,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_advancedOpen) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<ProductStatusFilter>(
                      value: widget.statusFilter,
                      isDense: true,
                      decoration: const InputDecoration(
                        labelText: 'Stato',
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: ProductStatusFilter.all,
                          child: Text('Tutti'),
                        ),
                        DropdownMenuItem(
                          value: ProductStatusFilter.expiring,
                          child: Text('In scadenza'),
                        ),
                        DropdownMenuItem(
                          value: ProductStatusFilter.expired,
                          child: Text('Scaduti'),
                        ),
                        DropdownMenuItem(
                          value: ProductStatusFilter.lowStock,
                          child: Text('Low stock'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) widget.onStatusChanged(v);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<ProductOpenStateFilter>(
                      value: widget.openStateFilter,
                      isDense: true,
                      decoration: const InputDecoration(
                        labelText: 'Apertura',
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: ProductOpenStateFilter.all,
                          child: Text('Aperti e non'),
                        ),
                        DropdownMenuItem(
                          value: ProductOpenStateFilter.opened,
                          child: Text('Aperti'),
                        ),
                        DropdownMenuItem(
                          value: ProductOpenStateFilter.unopened,
                          child: Text('Non aperti'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) widget.onOpenStateChanged(v);
                      },
                    ),
                  ),
                ],
              ),
              if (_advancedActive) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: widget.onReset,
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.onSurfaceVariant,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Reset filtri'),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
