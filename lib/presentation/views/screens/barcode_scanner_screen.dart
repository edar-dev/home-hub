import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../../domain/repositories/barcode_repository.dart';

/// Risultato scansione: codice e nome suggerito dalla cache (se presente).
typedef BarcodeScanResult = ({String barcode, String? suggestedName});

/// Scanner fullscreen; su Web solo inserimento manuale.
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController? _controller;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = MobileScannerController();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _finishWithBarcode(String raw) async {
    if (_handled || !mounted) return;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return;
    _handled = true;
    final repo = context.read<BarcodeRepository>();
    if (!kIsWeb) {
      await _controller?.stop();
    }
    await repo.recordScan(trimmed);
    final entry = await repo.lookupBarcode(trimmed);
    if (!mounted) return;
    Navigator.of(context).pop<BarcodeScanResult>(
      (barcode: trimmed, suggestedName: entry?.suggestedName),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('Codice a barre')),
        body: _ManualBarcodePanel(
          autofocus: true,
          onSubmit: _finishWithBarcode,
        ),
      );
    }

    final controller = _controller!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scansiona'),
        actions: [
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final torch = controller.value.torchState;
              final on = torch == TorchState.on;
              return IconButton(
                tooltip: 'Torcia',
                icon: Icon(on ? Icons.flash_on : Icons.flash_off),
                onPressed: torch == TorchState.unavailable
                    ? null
                    : () => controller.toggleTorch(),
              );
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (_handled) return;
              final codes = capture.barcodes;
              if (codes.isEmpty) return;
              final v = codes.first.rawValue ?? codes.first.displayValue;
              if (v != null && v.isNotEmpty) {
                _finishWithBarcode(v);
              }
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: FilledButton.tonal(
              onPressed: _handled
                  ? null
                  : () async {
                      final code = await showDialog<String>(
                        context: context,
                        builder: (ctx) {
                          final c = TextEditingController();
                          return AlertDialog(
                            title: const Text('Inserisci codice'),
                            content: TextField(
                              controller: c,
                              decoration: const InputDecoration(
                                hintText: 'EAN / barcode',
                              ),
                              autofocus: true,
                              onSubmitted: (s) =>
                                  Navigator.pop(ctx, s),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Annulla'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, c.text),
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                      if (code != null && code.trim().isNotEmpty) {
                        await _finishWithBarcode(code);
                      }
                    },
              child: const Text('Inserisci manualmente'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualBarcodePanel extends StatefulWidget {
  const _ManualBarcodePanel({
    required this.onSubmit,
    this.autofocus = false,
  });

  final Future<void> Function(String code) onSubmit;
  final bool autofocus;

  @override
  State<_ManualBarcodePanel> createState() => _ManualBarcodePanelState();
}

class _ManualBarcodePanelState extends State<_ManualBarcodePanel> {
  final _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    final t = _controller.text.trim();
    if (t.isEmpty) return;
    setState(() => _busy = true);
    await widget.onSubmit(t);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Su Web la fotocamera non è disponibile. Inserisci il codice a '
            'barre o l’EAN a mano.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            autofocus: widget.autofocus,
            decoration: const InputDecoration(
              labelText: 'Codice',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _go(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _go,
            child: _busy
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Continua'),
          ),
        ],
      ),
    );
  }
}
