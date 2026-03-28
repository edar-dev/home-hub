import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/product.dart';
import '../../layout/breakpoints.dart';
import '../../viewmodels/product_view_model.dart';
import '../widgets/product_card.dart';
import '../widgets/product_detail_body.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

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

  Widget _buildDetailPane(ProductViewModel vm) {
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
      onEdit: () => _embeddedEdit(p),
      onDelete: () => _embeddedDelete(p),
    );
  }

  Widget _buildListView(ProductViewModel vm, bool wide) {
    return RefreshIndicator(
      onRefresh: () => vm.loadProducts(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: vm.products.length,
        itemBuilder: (context, index) {
          final p = vm.products[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
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
                  borderRadius: BorderRadius.circular(12),
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
                onTap: () => _onCardTap(p, wide),
                onDelete: () => _confirmDelete(p.nome, p.id),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductViewModel vm, bool wide) {
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

    final list = _buildListView(vm, wide);
    if (!wide) return list;

    return Row(
      children: [
        Expanded(flex: 2, child: list),
        const VerticalDivider(width: 1),
        Expanded(flex: 3, child: _buildDetailPane(vm)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductViewModel>();

    if (_selectedId != null && _selectedProduct(vm.products) == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedId = null);
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = isWideWidth(constraints.maxWidth);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Inventario'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Cerca (prossimamente)',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ricerca in arrivo in una prossima versione'),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: vm.isLoading ? null : () => vm.loadProducts(),
                tooltip: 'Aggiorna',
              ),
            ],
          ),
          body: _buildBody(context, vm, wide),
          floatingActionButton: FloatingActionButton(
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
        );
      },
    );
  }
}
