import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/consumption_entry.dart';
import '../../../domain/entities/product.dart';
import '../../viewmodels/product_view_model.dart';
import '../widgets/stitch_top_app_bar.dart';

class QuickConsumptionScreen extends StatefulWidget {
  const QuickConsumptionScreen({
    super.key,
    required this.product,
    this.source = ConsumptionSource.manual,
  });

  final Product product;
  final ConsumptionSource source;

  @override
  State<QuickConsumptionScreen> createState() => _QuickConsumptionScreenState();
}

class _QuickConsumptionScreenState extends State<QuickConsumptionScreen> {
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _recipeCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  ConsumptionMeal? _meal;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product.typicalPortion;
    _amountCtrl.text =
        ((p ?? 1).toStringAsFixed(p != null && p % 1 != 0 ? 1 : 0));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _recipeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) return;
    setState(() => _busy = true);
    final vm = context.read<ProductViewModel>();
    final err = await vm.registerConsumption(
      product: widget.product,
      amount: amount,
      meal: _meal,
      recipe: _recipeCtrl.text,
      notes: _notesCtrl.text,
      source: widget.source,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.of(context).pop(true);
  }

  Widget _quick(double amount) {
    return ActionChip(
      label: Text(
          '${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 1)} ${widget.product.unit}'),
      onPressed: () =>
          _amountCtrl.text = amount.toStringAsFixed(amount % 1 == 0 ? 0 : 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StitchTopAppBar(
        title: 'Registra consumo',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: ListView(
            children: [
              Text(
                widget.product.nome,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Quantità usata (${widget.product.unit})',
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _quick(widget.product.typicalPortion ?? 1),
                  _quick((widget.product.typicalPortion ?? 1) * 2),
                  _quick((widget.product.typicalPortion ?? 1) * 3),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in ConsumptionMeal.values)
                    ChoiceChip(
                      label: Text(_mealLabel(m)),
                      selected: _meal == m,
                      onSelected: (_) => setState(() => _meal = m),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _recipeCtrl,
                decoration:
                    const InputDecoration(labelText: 'Ricetta (opzionale)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesCtrl,
                decoration:
                    const InputDecoration(labelText: 'Note (opzionale)'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _busy ? null : _submit,
                icon: const Icon(Icons.check),
                label: const Text('Conferma consumo'),
              ),
              TextButton(
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
                child: const Text('Annulla'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _mealLabel(ConsumptionMeal m) {
    return switch (m) {
      ConsumptionMeal.breakfast => 'Colazione',
      ConsumptionMeal.lunch => 'Pranzo',
      ConsumptionMeal.dinner => 'Cena',
      ConsumptionMeal.snack => 'Spuntino',
      ConsumptionMeal.other => 'Altro',
    };
  }
}
