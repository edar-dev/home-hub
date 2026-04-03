import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/location.dart';
import '../../../utils/location_validators.dart';
import '../../viewmodels/location_view_model.dart';
import '../widgets/stitch_top_app_bar.dart';
import '../widgets/validation_error_widget.dart';

class LocationFormScreen extends StatefulWidget {
  const LocationFormScreen({super.key, this.location});

  final Location? location;

  @override
  State<LocationFormScreen> createState() => _LocationFormScreenState();
}

class _LocationFormScreenState extends State<LocationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descController = TextEditingController();
  bool _saving = false;
  List<String> _summaryErrors = [];

  bool get _isEdit => widget.location != null;

  @override
  void initState() {
    super.initState();
    final l = widget.location;
    if (l != null) {
      _nomeController.text = l.nome;
      _descController.text = l.descrizione ?? '';
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _summaryErrors = []);
    if (!_formKey.currentState!.validate()) {
      setState(() => _summaryErrors = const [
            'Controlla i campi evidenziati in rosso.',
          ]);
      return;
    }

    final vm = context.read<LocationViewModel>();
    setState(() => _saving = true);
    String? err;
    if (_isEdit) {
      final desc = _descController.text.trim();
      err = await vm.updateLocation(
        widget.location!.copyWith(
          nome: _nomeController.text.trim(),
          descrizione: desc.isEmpty ? null : desc,
          clearDescrizione: desc.isEmpty,
        ),
      );
    } else {
      err = await vm.createLocation(
        nome: _nomeController.text.trim(),
        descrizione: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
      );
    }
    setState(() => _saving = false);

    if (!mounted) return;
    if (err == null) {
      Navigator.of(context).pop();
    } else {
      setState(() => _summaryErrors = [err!]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StitchTopAppBar(
        title: _isEdit ? 'Modifica luogo' : 'Nuovo luogo',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                ValidationErrorWidget(messages: _summaryErrors),
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    hintText: 'Obbligatorio',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => LocationValidators.validateNome(v),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Descrizione (opzionale)',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () => Navigator.of(context).maybePop(),
                        child: const Text('Annulla'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _saving ? null : _submit,
                        child: _saving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_isEdit ? 'Salva' : 'Aggiungi'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
