import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/storage_position.dart';
import '../../../utils/location_validators.dart';
import '../../viewmodels/location_view_model.dart';
import '../widgets/stitch_top_app_bar.dart';
import '../widgets/validation_error_widget.dart';

class PositionFormScreen extends StatefulWidget {
  const PositionFormScreen({
    super.key,
    this.position,
    this.initialLocationId,
  });

  final StoragePosition? position;
  final String? initialLocationId;

  @override
  State<PositionFormScreen> createState() => _PositionFormScreenState();
}

class _PositionFormScreenState extends State<PositionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descController = TextEditingController();
  String? _locationId;
  bool _saving = false;
  List<String> _summaryErrors = [];

  bool get _isEdit => widget.position != null;

  @override
  void initState() {
    super.initState();
    final p = widget.position;
    if (p != null) {
      _nomeController.text = p.nome;
      _descController.text = p.descrizione ?? '';
      _locationId = p.locationId;
    } else {
      _locationId = widget.initialLocationId;
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
    final locId = _locationId;
    if (locId == null || locId.isEmpty) {
      setState(() => _summaryErrors = const ['Seleziona un luogo.']);
      return;
    }

    final vm = context.read<LocationViewModel>();
    setState(() => _saving = true);
    String? err;
    if (_isEdit) {
      err = await vm.updatePosition(
        widget.position!.copyWith(
          nome: _nomeController.text.trim(),
          descrizione: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          locationId: locId,
        ),
      );
    } else {
      err = await vm.addPosition(
        locationId: locId,
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
    final vm = context.watch<LocationViewModel>();
    final locations = vm.items;

    return Scaffold(
      appBar: StitchTopAppBar(
        title: _isEdit ? 'Modifica posizione' : 'Nuova posizione',
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
                if (!_isEdit || locations.length > 1)
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use — selezione controllata da stato; `initialValue` non equivale a `value` su ogni rebuild.
                    value: _locationId != null &&
                            locations.any((e) => e.location.id == _locationId)
                        ? _locationId
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Luogo',
                    ),
                    items: locations
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.location.id,
                            child: Text(e.location.nome),
                          ),
                        )
                        .toList(),
                    onChanged:
                        _saving ? null : (v) => setState(() => _locationId = v),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Seleziona un luogo' : null,
                  ),
                if (!_isEdit || locations.length > 1)
                  const SizedBox(height: 16),
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome posizione',
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
