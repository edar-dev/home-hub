import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../viewmodels/analytics_view_model.dart';

class ExportActions extends StatelessWidget {
  const ExportActions({super.key});

  @override
  Widget build(BuildContext context) {
    final loading =
        context.select<AnalyticsViewModel, bool>((vm) => vm.isLoading);
    return Row(
      children: [
        FilledButton.icon(
          onPressed: loading
              ? null
              : () => context.read<AnalyticsViewModel>().exportPdf(),
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text('PDF'),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: loading
              ? null
              : () => context.read<AnalyticsViewModel>().exportCsv(),
          icon: const Icon(Icons.table_chart_outlined),
          label: const Text('CSV'),
        ),
      ],
    );
  }
}
