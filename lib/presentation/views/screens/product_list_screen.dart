import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/product_view_model.dart';
import '../widgets/product_card.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().loadProducts();
    });
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: vm.isLoading ? null : () => vm.loadProducts(),
            tooltip: 'Aggiorna',
          ),
        ],
      ),
      body: _buildBody(context, vm),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => const ProductFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductViewModel vm) {
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

    return RefreshIndicator(
      onRefresh: () => vm.loadProducts(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: vm.products.length,
        itemBuilder: (context, index) {
          final p = vm.products[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ProductCard(
              product: p,
              onTap: () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => ProductFormScreen(product: p),
                  ),
                );
              },
              onDelete: () => _confirmDelete(p.nome, p.id),
            ),
          );
        },
      ),
    );
  }
}
