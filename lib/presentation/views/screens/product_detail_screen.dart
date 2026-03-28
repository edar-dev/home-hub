import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/product.dart';
import '../../viewmodels/product_view_model.dart';
import '../widgets/product_detail_body.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminare il prodotto?'),
        content: Text('«${_product.nome}» verrà rimosso dall’inventario.'),
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
      await context.read<ProductViewModel>().deleteProduct(_product.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _openEdit() async {
    final vm = context.read<ProductViewModel>();
    final navigator = Navigator.of(context);
    await navigator.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ProductFormScreen(product: _product),
      ),
    );
    if (!context.mounted) return;
    await vm.loadProducts();
    if (!context.mounted) return;
    Product? updated;
    for (final p in vm.products) {
      if (p.id == _product.id) {
        updated = p;
        break;
      }
    }
    if (!context.mounted) return;
    if (updated == null) {
      navigator.pop();
    } else {
      setState(() => _product = updated!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Modifica',
            onPressed: _openEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Elimina',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ProductDetailBody(product: _product),
    );
  }
}
