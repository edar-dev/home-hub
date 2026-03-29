import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../viewmodels/shopping_list_view_model.dart';
import 'category_management_screen.dart';
import 'shopping_history_screen.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  Future<void> _shareList(BuildContext context) async {
    final vm = context.read<ShoppingListViewModel>();
    final list = vm.list;
    if (list == null || list.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nessuna voce da condividere.')),
      );
      return;
    }
    final buf = StringBuffer('${list.title}\n\n');
    for (final i in list.items) {
      final mark = i.done ? '☑' : '☐';
      buf.writeln('$mark ${i.quantity}x ${i.nome}');
    }
    await Share.share(buf.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Lista spesa'),
            actions: [
              IconButton(
                icon: const Icon(Icons.category_outlined),
                tooltip: 'Categorie',
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const CategoryManagementScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'Storico',
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const ShoppingHistoryScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Condividi',
                onPressed: () => _shareList(context),
              ),
            ],
          ),
          body: _buildBody(context, vm),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: vm.isLoading ? null : () => vm.generate(),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Genera da inventario'),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ShoppingListViewModel vm) {
    if (vm.isLoading && vm.list == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null && vm.list == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(vm.errorMessage!),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => vm.load(),
                child: const Text('Riprova'),
              ),
            ],
          ),
        ),
      );
    }
    final list = vm.list;
    if (list == null || list.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Lista vuota',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Genera voci da inventario (esauriti, poca quantità, '
                'scaduti negli ultimi 7 giorni).',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        if (list.items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: vm.isLoading ? null : () => vm.archive(),
                icon: const Icon(Icons.archive_outlined),
                label: const Text('Archivia lista'),
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.items.length,
            itemBuilder: (context, index) {
              final item = list.items[index];
              return CheckboxListTile(
                value: item.done,
                onChanged: vm.isLoading
                    ? null
                    : (v) => vm.toggleItem(item.id, v ?? false),
                title: Text(item.nome),
                subtitle: Text('Quantità: ${item.quantity}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
