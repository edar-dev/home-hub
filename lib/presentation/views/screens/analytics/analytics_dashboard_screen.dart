import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/analytics_view_model.dart';
import '../../../viewmodels/location_view_model.dart';
import 'widgets/analytics_filter_controls.dart';
import 'widgets/consumption_line_chart.dart';
import 'widgets/export_actions.dart';
import 'widgets/location_pie_chart.dart';
import 'widgets/metric_card.dart';
import 'widgets/quantity_bar_chart.dart';
import '../../widgets/stitch_top_app_bar.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LocationViewModel>().loadHierarchy();
      context.read<AnalyticsViewModel>().loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsViewModel>();
    final m = analytics.metrics;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StitchTopAppBar(
            title: 'Analisi',
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Cerca',
                onPressed: () {},
              ),
            ],
          ),
          Expanded(
            child: analytics.isLoading && m == null
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => analytics.loadAnalytics(),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                      children: [
                        const AnalyticsFilterControls(),
                        const SizedBox(height: 16),
                        const ExportActions(),
                        const SizedBox(height: 24),
                        if (analytics.errorMessage != null)
                          MaterialBanner(
                            content: Text(analytics.errorMessage!),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  analytics.clearError();
                                  analytics.loadAnalytics();
                                },
                                child: const Text('Riprova'),
                              ),
                            ],
                          ),
                        if (m != null) ...[
                          Text(
                            'Metriche',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (context, c) {
                              final w = c.maxWidth;
                              final cross = w > 600 ? 4 : 2;
                              return GridView.count(
                                crossAxisCount: cross,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1.15,
                                children: [
                                  MetricCard(
                                    title: 'Totale prodotti',
                                    value: '${m.totalProducts}',
                                    leadingIcon: Icons.inventory_2_outlined,
                                    accentColor:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  MetricCard(
                                    title: 'In scadenza',
                                    value: '${m.expiringIn7Days}',
                                    leadingIcon: Icons.notification_important,
                                    accentColor: Theme.of(context)
                                        .colorScheme
                                        .tertiary,
                                  ),
                                  MetricCard(
                                    title: 'Scaduti (30 gg)',
                                    value: '${m.expiredInLast30Days}',
                                    subtitle:
                                        'Sprechi ${m.wastePercentage.toStringAsFixed(1)}%',
                                    leadingIcon: Icons.event_busy,
                                    accentColor:
                                        Theme.of(context).colorScheme.error,
                                  ),
                                  MetricCard(
                                    title: 'Consumo medio',
                                    value: m.monthlyConsumptionAverage
                                        .toStringAsFixed(1),
                                    subtitle: '/ mese (stima)',
                                    leadingIcon: Icons.trending_up,
                                    accentColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Distribuzione per luogo',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          LocationPieChart(
                              points: analytics.locationDistribution),
                          const SizedBox(height: 24),
                          Text(
                            'Top 5 per quantità rimasta',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          QuantityBarChart(points: analytics.topByQuantity),
                          const SizedBox(height: 24),
                          Text(
                            'Trend consumo (stima, ultimi 3 mesi)',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Senza storico reale: valore ripartito in modo uniforme.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          ConsumptionLineChart(
                              points: analytics.consumptionTrend),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
