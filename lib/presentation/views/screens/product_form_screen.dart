import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/photo_storage_service.dart';
import '../../../domain/entities/location_with_positions.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/product_category.dart';
import '../../../domain/repositories/barcode_repository.dart';
import '../../../domain/repositories/category_repository.dart';
import '../../../utils/product_validators.dart';
import '../../viewmodels/location_view_model.dart';
import '../../viewmodels/product_view_model.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/quantity_field.dart';
import '../widgets/validation_error_widget.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({
    super.key,
    this.product,
    this.initialBarcode,
    this.initialSuggestedName,
    this.initialPositionId,
  }) : assert(
          product == null ||
              (initialBarcode == null &&
                  initialSuggestedName == null &&
                  initialPositionId == null),
          'parametri initial* solo per nuovo prodotto',
        );

  /// Se null, creazione; altrimenti modifica.
  final Product? product;

  /// Da scanner: codice precompilato (senza [product]).
  final String? initialBarcode;

  /// Da cache barcode: nome suggerito (senza [product]).
  final String? initialSuggestedName;

  /// Posizione pre-selezionata in creazione rapida (senza [product]).
  final String? initialPositionId;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _totaleController = TextEditingController();
  final _rimastaController = TextEditingController();

  DateTime? _dataAcquisto;
  DateTime? _dataScadenza;
  DateTime? _dataApertura;
  String? _positionId;
  bool _saving = false;
  List<String> _summaryErrors = [];

  XFile? _pickedImage;
  bool _removeImage = false;

  String? _categoryId;
  List<ProductCategory> _categories = [];

  bool get _isEdit => widget.product != null;

  String? get _effectiveCategoryId {
    final id = _categoryId;
    if (id == null) return null;
    for (final c in _categories) {
      if (c.id == id) return id;
    }
    return null;
  }

  int _effectiveTotale() {
    final t = int.tryParse(_totaleController.text.trim());
    if (t == null || t < 1) return 1;
    return t;
  }

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _nomeController.text = p.nome;
      if (p.barcode != null) {
        _barcodeController.text = p.barcode!;
      }
      _totaleController.text = p.quantitaTotale.toString();
      _rimastaController.text = p.quantitaRimasta.toString();
      _dataAcquisto = p.dataAcquisto;
      _dataScadenza = p.dataScadenza;
      _dataApertura = p.dataApertura;
      _positionId = p.positionId;
      _categoryId = p.categoryId;
    } else {
      _totaleController.text = '1';
      _rimastaController.text = '1';
      _positionId = widget.initialPositionId;
      final ib = widget.initialBarcode;
      if (ib != null && ib.isNotEmpty) {
        _barcodeController.text = ib;
      }
      final sn = widget.initialSuggestedName;
      if (sn != null && sn.isNotEmpty) {
        _nomeController.text = sn;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final loc = context.read<LocationViewModel>();
      if (loc.items.isEmpty) {
        loc.loadHierarchy();
      }
      final cats = await context.read<CategoryRepository>().getAll();
      if (!mounted) return;
      setState(() => _categories = cats);
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _barcodeController.dispose();
    _totaleController.dispose();
    _rimastaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galleria'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Fotocamera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (src == null) return;
    final picker = ImagePicker();
    final x = await picker.pickImage(source: src);
    if (x == null) return;
    setState(() {
      _pickedImage = x;
      _removeImage = false;
    });
  }

  Future<void> _confirmDelete() async {
    final p = widget.product;
    if (p == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminare il prodotto?'),
        content: Text('«${p.nome}» verrà rimosso dall’inventario.'),
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
      final photo = context.read<PhotoStorageService>();
      final vm = context.read<ProductViewModel>();
      await photo.deleteIfExists(p.imageRelativePath);
      if (!mounted) return;
      final err = await vm.deleteProduct(p.id);
      if (!mounted) return;
      if (err == null) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }

  Future<void> _submit() async {
    setState(() => _summaryErrors = []);
    if (!_formKey.currentState!.validate()) {
      setState(() => _summaryErrors = const [
        'Controlla i campi evidenziati in rosso.',
      ]);
      return;
    }

    final nome = _nomeController.text.trim();
    final totStr = _totaleController.text.trim();
    final rimStr = _rimastaController.text.trim();
    final totale = totStr.isEmpty ? 1 : (int.tryParse(totStr) ?? 1);
    final totaleClamped = totale < 1 ? 1 : totale;
    final rimasta = rimStr.isEmpty
        ? totaleClamped
        : (int.tryParse(rimStr) ?? 0);

    final id = widget.product?.id ?? const Uuid().v4();

    final barcodeRaw = _barcodeController.text.trim();
    final barcode = barcodeRaw.isEmpty ? null : barcodeRaw;

    final productDraft = Product(
      id: id,
      nome: nome,
      dataAcquisto: _dataAcquisto,
      dataScadenza: _dataScadenza,
      dataApertura: _dataApertura,
      quantitaTotale: totaleClamped,
      quantitaRimasta: rimasta,
      positionId: _positionId,
      barcode: barcode,
      imageRelativePath: _removeImage
          ? null
          : (widget.product?.imageRelativePath),
      categoryId: _categoryId,
    );

    final validation = ProductValidators.validateProduct(productDraft);
    if (validation != null) {
      setState(() => _summaryErrors = [validation]);
      return;
    }

    final photo = context.read<PhotoStorageService>();
    String? imageRel = widget.product?.imageRelativePath;
    if (!kIsWeb) {
      if (_removeImage) {
        await photo.deleteIfExists(widget.product?.imageRelativePath);
        imageRel = null;
      } else if (_pickedImage != null) {
        final bytes = await _pickedImage!.readAsBytes();
        imageRel = await photo.saveProductPhotoFromBytes(bytes, id);
        if (_isEdit) {
          await photo.deleteIfExists(widget.product?.imageRelativePath);
        }
      }
    }

    if (!mounted) return;

    final product = Product(
      id: id,
      nome: nome,
      dataAcquisto: _dataAcquisto,
      dataScadenza: _dataScadenza,
      dataApertura: _dataApertura,
      quantitaTotale: totaleClamped,
      quantitaRimasta: rimasta,
      positionId: _positionId,
      barcode: barcode,
      imageRelativePath: imageRel,
      categoryId: _categoryId,
    );

    final vm = context.read<ProductViewModel>();
    final barcodeRepo = context.read<BarcodeRepository>();
    setState(() => _saving = true);
    final err = _isEdit
        ? await vm.updateProduct(product)
        : await vm.createProduct(product);
    if (!mounted) return;
    setState(() => _saving = false);

    if (err == null) {
      if (product.barcode != null && product.barcode!.isNotEmpty) {
        await barcodeRepo.cacheBarcodeProduct(
          barcode: product.barcode!,
          suggestedName: product.nome,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
      setState(() => _summaryErrors = [err]);
    }
  }

  Widget _buildImagePreview() {
    final photo = context.read<PhotoStorageService>();
    if (_pickedImage != null) {
      return FutureBuilder(
        future: _pickedImage!.readAsBytes(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return Image.memory(
            snap.data!,
            height: 120,
            fit: BoxFit.contain,
          );
        },
      );
    }
    final p = widget.product;
    if (!_removeImage && p?.imageRelativePath != null) {
      final f = photo.resolveFile(p!.imageRelativePath!);
      if (f.existsSync()) {
        return Image.file(f, height: 120, fit: BoxFit.contain);
      }
    }
    return const SizedBox.shrink();
  }

  bool _positionStillValid(List<LocationWithPositions> items) {
    final pid = _positionId;
    if (pid == null) return true;
    for (final row in items) {
      for (final pos in row.positions) {
        if (pos.id == pid) return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final locVm = context.watch<LocationViewModel>();
    final positionItems = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('Nessuna posizione'),
      ),
      ...locVm.items.expand(
        (row) => row.positions.map(
          (pos) => DropdownMenuItem<String?>(
            value: pos.id,
            child: Text('${row.location.nome} — ${pos.nome}'),
          ),
        ),
      ),
    ];
    final effectivePositionId =
        _positionStillValid(locVm.items) ? _positionId : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifica prodotto' : 'Nuovo prodotto'),
        actions: [
          if (_isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Elimina',
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ValidationErrorWidget(messages: _summaryErrors),
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    hintText: 'Obbligatorio',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => ProductValidators.validateNome(v),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _barcodeController,
                  decoration: const InputDecoration(
                    labelText: 'Codice a barre (opzionale)',
                  ),
                  maxLength: 64,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: _effectiveCategoryId, // ignore: deprecated_member_use
                  decoration: const InputDecoration(
                    labelText: 'Categoria (opzionale)',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Nessuna categoria'),
                    ),
                    ..._categories.map(
                      (c) => DropdownMenuItem<String?>(
                        value: c.id,
                        child: Text(c.nome),
                      ),
                    ),
                  ],
                  onChanged: _saving
                      ? null
                      : (v) => setState(() => _categoryId = v),
                ),
                const SizedBox(height: 8),
                if (!kIsWeb) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Foto',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _saving ? null : _pickImage,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text('Scegli foto'),
                      ),
                      const SizedBox(width: 12),
                      if (widget.product?.imageRelativePath != null ||
                          _pickedImage != null)
                        TextButton(
                          onPressed: _saving
                              ? null
                              : () => setState(() {
                                    _pickedImage = null;
                                    _removeImage = true;
                                  }),
                          child: const Text('Rimuovi'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildImagePreview(),
                ] else
                  Text(
                    'Foto prodotto: disponibile su mobile/desktop.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: effectivePositionId, // ignore: deprecated_member_use
                  decoration: const InputDecoration(
                    labelText: 'Posizione (opzionale)',
                  ),
                  items: positionItems,
                  onChanged: _saving
                      ? null
                      : (v) => setState(() => _positionId = v),
                ),
                const SizedBox(height: 16),
                DatePickerField(
                  label: 'Data acquisto',
                  value: _dataAcquisto,
                  onChanged: (d) => setState(() => _dataAcquisto = d),
                ),
                const SizedBox(height: 12),
                DatePickerField(
                  label: 'Data scadenza',
                  value: _dataScadenza,
                  onChanged: (d) => setState(() => _dataScadenza = d),
                  firstDate: _dataAcquisto,
                ),
                const SizedBox(height: 12),
                DatePickerField(
                  label: 'Data apertura (opzionale)',
                  value: _dataApertura,
                  onChanged: (d) => setState(() => _dataApertura = d),
                ),
                const SizedBox(height: 16),
                Text(
                  'Quantità',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Lascia vuoto per usare 1 come valore predefinito.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: QuantityField(
                        label: 'Totale',
                        controller: _totaleController,
                        min: 1,
                        max: 9999,
                        onChanged: () {
                          setState(() {});
                          _formKey.currentState?.validate();
                        },
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final n = int.tryParse(v.trim());
                          if (n == null) return 'Numero non valido';
                          return ProductValidators.validateQuantitaTotale(n);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: QuantityField(
                        label: 'Rimasti',
                        controller: _rimastaController,
                        min: 0,
                        max: _effectiveTotale(),
                        onChanged: () => _formKey.currentState?.validate(),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final n = int.tryParse(v.trim());
                          if (n == null) return 'Numero non valido';
                          return ProductValidators.validateQuantitaRimasta(
                            n,
                            _effectiveTotale(),
                          );
                        },
                      ),
                    ),
                  ],
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
                        key: const ValueKey<String>('product-form-submit'),
                        onPressed: _saving ? null : _submit,
                        child: _saving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
