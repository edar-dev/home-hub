import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/product.dart';
import '../../utils/product_validators.dart';
import '../../viewmodels/product_view_model.dart';
import '../widgets/date_field.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  /// Se null, creazione; altrimenti modifica.
  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _totaleController = TextEditingController();
  final _rimastaController = TextEditingController();

  DateTime? _dataAcquisto;
  DateTime? _dataScadenza;
  DateTime? _dataApertura;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _nomeController.text = p.nome;
      _totaleController.text = p.quantitaTotale.toString();
      _rimastaController.text = p.quantitaRimasta.toString();
      _dataAcquisto = p.dataAcquisto;
      _dataScadenza = p.dataScadenza;
      _dataApertura = p.dataApertura;
    } else {
      _totaleController.text = '1';
      _rimastaController.text = '1';
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _totaleController.dispose();
    _rimastaController.dispose();
    super.dispose();
  }

  int? _parsePositiveInt(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    final v = int.tryParse(s.trim());
    if (v == null) return null;
    return v;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final nome = _nomeController.text.trim();
    final totale = _parsePositiveInt(_totaleController.text);
    final rimasta = _parsePositiveInt(_rimastaController.text);

    if (totale == null || rimasta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantità non valide')),
      );
      return;
    }

    final id = widget.product?.id ?? const Uuid().v4();
    final product = Product(
      id: id,
      nome: nome,
      quantitaTotale: totale,
      quantitaRimasta: rimasta,
    )
      ..dataAcquisto = _dataAcquisto
      ..dataScadenza = _dataScadenza
      ..dataApertura = _dataApertura;

    final validation = ProductValidators.validateProduct(product);
    if (validation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validation)),
      );
      return;
    }

    setState(() => _saving = true);
    final vm = context.read<ProductViewModel>();
    final err = _isEdit
        ? await vm.updateProduct(product)
        : await vm.addProduct(product);
    setState(() => _saving = false);

    if (!mounted) return;
    if (err == null) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifica prodotto' : 'Nuovo prodotto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => ProductValidators.validateNome(v),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _totaleController,
                    decoration: const InputDecoration(
                      labelText: 'Quantità totale',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = _parsePositiveInt(v);
                      if (n == null) return 'Inserisci un numero intero';
                      return ProductValidators.validateQuantitaTotale(n);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _rimastaController,
                    decoration: const InputDecoration(
                      labelText: 'Quantità rimasta',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = _parsePositiveInt(v);
                      if (n == null) return 'Inserisci un numero intero';
                      final tot = _parsePositiveInt(_totaleController.text);
                      if (tot == null) return null;
                      return ProductValidators.validateQuantitaRimasta(n, tot);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DateFormField(
              label: 'Data acquisto',
              value: _dataAcquisto,
              onChanged: (d) => setState(() => _dataAcquisto = d),
            ),
            const SizedBox(height: 12),
            DateFormField(
              label: 'Data scadenza',
              value: _dataScadenza,
              onChanged: (d) => setState(() => _dataScadenza = d),
              firstDate: _dataAcquisto,
            ),
            const SizedBox(height: 12),
            DateFormField(
              label: 'Data apertura',
              value: _dataApertura,
              onChanged: (d) => setState(() => _dataApertura = d),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEdit ? 'Salva' : 'Aggiungi'),
            ),
          ],
        ),
      ),
    );
  }
}
