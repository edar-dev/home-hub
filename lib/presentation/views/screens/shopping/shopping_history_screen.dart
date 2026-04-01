import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/shopping_list.dart';
import '../../../../domain/repositories/shopping_list_repository.dart';
import '../../widgets/stitch_top_app_bar.dart';

class ShoppingHistoryScreen extends StatefulWidget {
  const ShoppingHistoryScreen({super.key});

  @override
  State<ShoppingHistoryScreen> createState() => _ShoppingHistoryScreenState();
}

class _ShoppingHistoryScreenState extends State<ShoppingHistoryScreen> {
  Future<List<ShoppingList>>? _future;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _future = context.read<ShoppingListRepository>().getHistory();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StitchTopAppBar(
        title: 'Storico liste',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: FutureBuilder<List<ShoppingList>>(
        future: _future ?? Future.value(const []),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('Nessuna lista archiviata.'));
          }
          final fmt = DateFormat.yMMMd('it_IT');
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final sl = list[i];
              final when = sl.completedAt;
              return Card(
                child: ExpansionTile(
                  title: Text(sl.title),
                  subtitle: Text(
                    when != null
                        ? 'Completata: ${fmt.format(when)}'
                        : '—',
                  ),
                  children: [
                    for (final it in sl.items)
                      ListTile(
                        dense: true,
                        leading: Icon(
                          it.done ? Icons.check_box : Icons.check_box_outline_blank,
                        ),
                        title: Text(it.nome),
                        trailing: Text('${it.quantity}'),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
