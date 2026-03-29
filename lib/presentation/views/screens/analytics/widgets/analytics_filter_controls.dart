import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../viewmodels/analytics_view_model.dart';
import '../../../../viewmodels/location_view_model.dart';

class AnalyticsFilterControls extends StatefulWidget {
  const AnalyticsFilterControls({super.key});

  @override
  State<AnalyticsFilterControls> createState() =>
      _AnalyticsFilterControlsState();
}

class _AnalyticsFilterControlsState extends State<AnalyticsFilterControls> {
  String _preset = 'month';

  Future<void> _applyPreset(String code, AnalyticsViewModel analytics) async {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    late DateTime start;
    switch (code) {
      case 'week':
        start = end.subtract(const Duration(days: 7));
        break;
      case 'month':
        start = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'quarter':
        start = DateTime(now.year, now.month - 3, now.day);
        break;
      case 'year':
        start = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        start = end.subtract(const Duration(days: 30));
    }
    setState(() => _preset = code);
    await analytics.updateDateRange(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsViewModel>();
    final locVm = context.watch<LocationViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Periodo',
            border: OutlineInputBorder(),
          ),
          // ignore: deprecated_member_use
          value: _preset,
          items: const [
            DropdownMenuItem(value: 'week', child: Text('Ultima settimana')),
            DropdownMenuItem(value: 'month', child: Text('Ultimo mese')),
            DropdownMenuItem(
              value: 'quarter',
              child: Text('Ultimo trimestre'),
            ),
            DropdownMenuItem(value: 'year', child: Text('Ultimo anno')),
          ],
          onChanged: (v) {
            if (v != null) _applyPreset(v, analytics);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String?>(
          decoration: const InputDecoration(
            labelText: 'Luogo',
            border: OutlineInputBorder(),
          ),
          // ignore: deprecated_member_use
          value: analytics.selectedLocationId,
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Tutti i luoghi'),
            ),
            ...locVm.items.map(
              (row) => DropdownMenuItem<String?>(
                value: row.location.id,
                child: Text(row.location.nome),
              ),
            ),
          ],
          onChanged: (v) => analytics.filterByLocation(v),
        ),
      ],
    );
  }
}
