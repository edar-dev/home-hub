import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Quantità con pulsanti +/- e validazione tramite [validator].
class QuantityField extends StatelessWidget {
  const QuantityField({
    super.key,
    required this.label,
    required this.controller,
    this.min = 0,
    this.max = 9999,
    this.onChanged,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final int min;
  final int max;
  final VoidCallback? onChanged;
  final FormFieldValidator<String>? validator;

  int _readValue() {
    final v = int.tryParse(controller.text.trim());
    return v ?? min;
  }

  void _setValue(int v) {
    final clamped = v.clamp(min, max);
    controller.text = clamped.toString();
    onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () => _setValue(_readValue() - 1),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _setValue(_readValue() + 1),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: validator,
      onChanged: (_) => onChanged?.call(),
    );
  }
}
