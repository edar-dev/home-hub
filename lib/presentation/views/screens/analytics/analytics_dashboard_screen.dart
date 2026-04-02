import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/analytics_metrics.dart';
import '../../../../domain/entities/chart_data_point.dart';
import '../../../mixins/deferred_shell_tab_load_mixin.dart';
import '../../../viewmodels/analytics_view_model.dart';
import '../../../viewmodels/home_shell_tab_controller.dart';
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

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with DeferredShellTabLoadMixin {
  @override
  int get deferredShellTabIndex => HomeShellTabController.tabAnalytics;

  @override
  void onDeferredShellTabVisible() {
    if (!mounted) return;
    context.read<LocationViewModel>().loadHierarchy();
    context.read<AnalyticsViewModel>().loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<
        AnalyticsViewModel,
        ({
          bool isLoading,
          AnalyticsMetrics? metrics,
          String? errorMessage,
          List<ChartDataPoint> topConsumed,
          List<ChartDataPoint> recentConsumptionSummary,
          List<ChartDataPoint> locationDistribution,
          List<ChartDataPoint> topByQuantity,
          List<ChartDataPoint> consumptionTrend,
          List<ChartDataPoint> monthlyByCategory,
        })>(
      selector: (_, vm) => (
        isLoading: vm.isLoading,
        metrics: vm.metrics,
        errorMessage: vm.errorMessage,
        topConsumed: vm.topConsumed,
        recentConsumptionSummary: vm.recentConsumptionSummary,
        locationDistribution: vm.locationDistribution,
        topByQuantity: vm.topByQuantity,
        consumptionTrend: vm.consumptionTrend,
        monthlyByCategory: vm.monthlyByCategory,
      ),
      builder: (context, s, _) {
        final m = s.metrics;
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
                child: s.isLoading && m == null
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () =>
                            context.read<AnalyticsViewModel>().loadAnalytics(),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                          children: [
                            const AnalyticsFilterControls(),
                            const SizedBox(height: 16),
                            const ExportActions(),
                            const SizedBox(height: 24),
                            if (s.errorMessage != null)
                              MaterialBanner(
                                content: Text(s.errorMessage!),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      final av =
                                          context.read<AnalyticsViewModel>();
                                      av.clearError();
                                      av.loadAnalytics();
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
                                  // Mobile: leggermente più alto del quadrato per evitare overflow
                                  // su titoli lunghi + sottotitolo (Stitch resta vicino a square).
                                  final ratio = cross == 2 ? 0.94 : 1.25;
                                  return GridView.count(
                                    crossAxisCount: cross,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: ratio,
                                    children: [
                                      MetricCard(
                                        title: 'Totale prodotti',
                                        value: '${m.totalProducts}',
                                        leadingIcon: Icons.inventory_2_outlined,
                                        accentColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      MetricCard(
                                        title: 'In scadenza',
                                        value: '${m.expiringIn7Days}',
                                        leadingIcon:
                                            Icons.notification_important,
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
                                'Prodotti quasi finiti',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              MetricCard(
                                title: 'Quasi esauriti',
                                value: '${m.almostEmptyProducts}',
                                subtitle: 'Stima <= 3 giorni',
                                leadingIcon: Icons.warning_amber_rounded,
                                accentColor:
                                    Theme.of(context).colorScheme.tertiary,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Top consumi (30 giorni)',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              QuantityBarChart(
                                  points: s.topConsumed.take(5).toList()),
                              const SizedBox(height: 24),
                              Text(
                                'Sintesi consumi recenti (7 giorni)',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              if (s.recentConsumptionSummary.isEmpty)
                                const Text('Nessun consumo registrato')
                              else
                                ...s.recentConsumptionSummary.map(
                                  (e) => ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(e.label),
                                    trailing: Text(
                                      e.value.toStringAsFixed(1),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              Text(
                                'Distribuzione per luogo',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              LocationPieChart(points: s.locationDistribution),
                              const SizedBox(height: 24),
                              Text(
                                'Top 5 per quantità rimasta',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              QuantityBarChart(points: s.topByQuantity),
                              const SizedBox(height: 24),
                              Text(
                                'Trend consumo (ultimi 3 mesi)',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Basato sugli eventi reali di consumo registrati.',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              ConsumptionLineChart(points: s.consumptionTrend),
                              const SizedBox(height: 24),
                              Text(
                                'Consumi per categoria (mese corrente)',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              QuantityBarChart(points: s.monthlyByCategory),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
