import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/entities/consumption_entry.dart';
import '../../layout/breakpoints.dart';
import '../../viewmodels/location_view_model.dart';
import '../../viewmodels/product_view_model.dart';
import '../widgets/product_card.dart';
import '../widgets/product_detail_body.dart';
import '../widgets/product_placement_helper.dart';
import '../widgets/stitch_top_app_bar.dart';
import 'barcode_scanner_screen.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';
import 'quick_consumption_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().loadProducts();
      context.read<LocationViewModel>().loadHierarchy();
    });
  }

  Product? _selectedProduct(List<Product> products) {
    if (_selectedId == null) return null;
    for (final p in products) {
      if (p.id == _selectedId) return p;
    }
    return null;
  }

  Future<void> _confirmDelete(String nome, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminare il prodotto?'),
        content: Text('«$nome» verrà rimosso dall’inventario.'),
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
      await context.read<ProductViewModel>().deleteProduct(id);
      if (_selectedId == id) {
        setState(() => _selectedId = null);
      }
    }
  }

  Future<bool> _confirmDismissDelete(String nome) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminare il prodotto?'),
        content: Text('«$nome» verrà rimosso dall’inventario.'),
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
    return ok == true;
  }

  void _onCardTap(Product p, bool wide) {
    if (wide) {
      setState(() => _selectedId = p.id);
    } else {
      final vmNav = context.read<ProductViewModel>();
      Navigator.of(context)
          .push<void>(
        MaterialPageRoute<void>(
          builder: (_) => ProductDetailScreen(product: p),
        ),
      )
          .then((_) {
        vmNav.loadProducts();
      });
    }
  }

  Future<void> _embeddedEdit(Product p) async {
    final vm = context.read<ProductViewModel>();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ProductFormScreen(product: p),
      ),
    );
    if (!context.mounted) return;
    await vm.loadProducts();
    if (!context.mounted) return;
    var stillThere = false;
    for (final x in vm.products) {
      if (x.id == p.id) {
        stillThere = true;
        break;
      }
    }
    if (!context.mounted) return;
    if (!stillThere) {
      setState(() => _selectedId = null);
    } else {
      setState(() {});
    }
  }

  Future<void> _embeddedDelete(Product p) async {
    await _confirmDelete(p.nome, p.id);
  }

  Future<void> _openBarcodeScanner() async {
    final result = await Navigator.of(context).push<BarcodeScanResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const BarcodeScannerScreen(),
      ),
    );
    if (!mounted || result == null) return;
    final vm = context.read<ProductViewModel>();
    Product? match;
    for (final p in vm.products) {
      if (p.barcode != null && p.barcode == result.barcode) {
        match = p;
        break;
      }
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => match != null
            ? QuickConsumptionScreen(
                product: match,
                source: ConsumptionSource.scanner,
              )
            : ProductFormScreen(
                initialBarcode: result.barcode,
                initialSuggestedName: result.suggestedName,
              ),
      ),
    );
    if (!mounted) return;
    await vm.loadProducts();
  }

  Future<void> _openQuickConsumption(Product product) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => QuickConsumptionScreen(product: product),
      ),
    );
    if (!mounted) return;
    await context.read<ProductViewModel>().loadProducts();
  }

  Widget _buildDetailPane(
    ProductViewModel vm,
    Map<String, (String, String)> placementIndex,
  ) {
    final p = _selectedProduct(vm.products);
    if (p == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Seleziona un prodotto dalla lista',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ProductDetailBody(
      product: p,
      embedded: true,
      placementLine: placementLineForProduct(p, placementIndex),
      onConsume: () => _openQuickConsumption(p),
      onEdit: () => _embeddedEdit(p),
      onDelete: () => _embeddedDelete(p),
    );
  }

  Widget _inventoryQuickChips(
    BuildContext context,
    ProductViewModel vm,
    LocationViewModel locVm,
  ) {
    final scheme = Theme.of(context).colorScheme;
    Widget capsule(String label, bool selected, VoidCallback onTap) {
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Material(
          color: selected ? scheme.primary : scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                label,
                style: TextStyle(
                  color:
                      selected ? scheme.onPrimary : scheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final rows = locVm.items.take(3).toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          capsule(
            'Tutti',
            vm.quickInventoryChip == InventoryQuickChip.tutti,
            () => unawaited(
              vm.setQuickInventoryChip(InventoryQuickChip.tutti),
            ),
          ),
          capsule(
            'Scadenza',
            vm.quickInventoryChip == InventoryQuickChip.scadenza,
            () => unawaited(
              vm.setQuickInventoryChip(InventoryQuickChip.scadenza),
            ),
          ),
          capsule(
            'Basso stock',
            vm.quickInventoryChip == InventoryQuickChip.bassoStock,
            () => unawaited(
              vm.setQuickInventoryChip(InventoryQuickChip.bassoStock),
            ),
          ),
          ...rows.map((row) {
            final id = row.location.id;
            final sel = vm.quickInventoryChip == InventoryQuickChip.luogo &&
                vm.filterLocationId == id;
            return capsule(
              row.location.nome,
              sel,
              () => unawaited(
                vm.setQuickInventoryChip(
                  InventoryQuickChip.luogo,
                  locationId: id,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildListView(
    ProductViewModel vm,
    bool wide,
    Map<String, (String, String)> placementIndex,
  ) {
    return RefreshIndicator(
      onRefresh: () => vm.loadProducts(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
        itemCount: vm.displayedProducts.length,
        itemBuilder: (context, index) {
          final p = vm.displayedProducts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Dismissible(
              key: ValueKey(p.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async {
                final ok = await _confirmDismissDelete(p.nome);
                if (ok != true || !context.mounted) return false;
                await context.read<ProductViewModel>().deleteProduct(p.id);
                if (!context.mounted) return true;
                if (_selectedId == p.id) {
                  setState(() => _selectedId = null);
                }
                return true;
              },
              onDismissed: (_) {},
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  size: 32,
                ),
              ),
              child: ProductCard(
                key: ValueKey('card-${p.id}'),
                product: p,
                placementLine: placementLineForProduct(p, placementIndex),
                onTap: () => _onCardTap(p, wide),
                onConsume: () => _openQuickConsumption(p),
                onDelete: () => _confirmDelete(p.nome, p.id),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ProductViewModel vm,
    bool wide,
    Map<String, (String, String)> placementIndex,
  ) {
    if (vm.isLoading && vm.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null && vm.products.isEmpty) {
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
              Text(
                vm.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => vm.loadProducts(),
                child: const Text('Riprova'),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nessun prodotto',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Tocca + per aggiungerne uno.'),
          ],
        ),
      );
    }

    if (vm.displayedProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_alt_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nessun prodotto in questo luogo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Modifica il filtro o assegna prodotti a una posizione.'),
          ],
        ),
      );
    }

    final list = _buildListView(vm, wide, placementIndex);
    if (!wide) return list;

    return Row(
      children: [
        Expanded(flex: 2, child: list),
        const VerticalDivider(width: 1),
        Expanded(flex: 3, child: _buildDetailPane(vm, placementIndex)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<
        ProductViewModel,
        (bool, String?, int, int, int, String?, InventoryQuickChip)>(
      selector: (_, vm) => (
        vm.isLoading,
        vm.errorMessage,
        vm.products.length,
        vm.displayedProducts.length,
        vm.displayUiGeneration,
        vm.filterLocationId,
        vm.quickInventoryChip,
      ),
      builder: (context, _, __) {
        final vm = context.read<ProductViewModel>();
        final locVm = context.watch<LocationViewModel>();
        final placementIndex = buildPlacementIndex(locVm.items);

        if (_selectedId != null && _selectedProduct(vm.products) == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedId = null);
          });
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = isWideWidth(constraints.maxWidth);
            final scheme = Theme.of(context).colorScheme;
            return Scaffold(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StitchTopAppBar(
                    title: 'Il Tuo Inventario',
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.search),
                        tooltip: 'Cerca (prossimamente)',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Ricerca in arrivo in una prossima versione',
                              ),
                            ),
                          );
                        },
                      ),
                      PopupMenuButton<String?>(
                        icon: const Icon(Icons.filter_list_outlined),
                        tooltip: 'Filtra per luogo',
                        onSelected: (id) {
                          unawaited(vm.setLocationFilter(id));
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem<String?>(
                            value: null,
                            child: Text('Tutti i prodotti'),
                          ),
                          ...locVm.items.map(
                            (e) => PopupMenuItem<String?>(
                              value: e.location.id,
                              child: Text(e.location.nome),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed:
                            vm.isLoading ? null : () => vm.loadProducts(),
                        tooltip: 'Aggiorna',
                      ),
                    ],
                  ),
                  _inventoryQuickChips(context, vm, locVm),
                  Expanded(
                    child: _buildBody(context, vm, wide, placementIndex),
                  ),
                ],
              ),
              floatingActionButton: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton.small(
                    key: const ValueKey<String>('fab-consume'),
                    heroTag: 'fab-consume',
                    backgroundColor: scheme.tertiaryContainer,
                    foregroundColor: scheme.onTertiaryContainer,
                    onPressed: vm.displayedProducts.isEmpty
                        ? null
                        : () => _openQuickConsumption(vm.displayedProducts.first),
                    child: const Icon(Icons.restaurant_outlined),
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton.small(
                    key: const ValueKey<String>('fab-scan'),
                    heroTag: 'fab-scan',
                    backgroundColor: scheme.surfaceContainerHigh,
                    foregroundColor: scheme.primary,
                    onPressed: _openBarcodeScanner,
                    child: const Icon(Icons.qr_code_scanner_outlined),
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton(
                    key: const ValueKey<String>('fab-product'),
                    heroTag: 'fab-product',
                    onPressed: () async {
                      final vmFab = context.read<ProductViewModel>();
                      await Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const ProductFormScreen(),
                        ),
                      );
                      if (!context.mounted) return;
                      await vmFab.loadProducts();
                    },
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
