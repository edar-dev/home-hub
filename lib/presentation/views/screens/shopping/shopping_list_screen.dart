import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../viewmodels/shopping_list_view_model.dart';
import '../../widgets/stitch_top_app_bar.dart';
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

  Widget _gradientGenerateButton(BuildContext context, ShoppingListViewModel vm) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: vm.isLoading ? null : () => vm.generate(),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              colors: [scheme.primary, scheme.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Genera automatica',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StitchTopAppBar(
                title: 'Lista della Spesa',
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
                    icon: const Icon(Icons.ios_share_outlined),
                    tooltip: 'Condividi',
                    onPressed: () => _shareList(context),
                  ),
                ],
              ),
              Expanded(child: _buildBody(context, vm)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ShoppingListViewModel vm) {
    final scheme = Theme.of(context).colorScheme;
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
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Lista vuota',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Genera voci da inventario (esauriti, poca quantità, '
                'scaduti negli ultimi 7 giorni).',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              _gradientGenerateButton(context, vm),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _gradientGenerateButton(context, vm),
                const SizedBox(width: 12),
                Material(
                  color: scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => _shareList(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.share_outlined, color: scheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Condividi',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: scheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (list.items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            itemCount: list.items.length,
            itemBuilder: (context, index) {
              final item = list.items[index];
              final borderAccent = index.isEven ? scheme.error : scheme.tertiary;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border(
                      left: BorderSide(color: borderAccent, width: 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CheckboxListTile(
                    value: item.done,
                    onChanged: vm.isLoading
                        ? null
                        : (v) => vm.toggleItem(item.id, v ?? false),
                    title: Text(
                      item.nome,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Quantità: ${item.quantity}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
