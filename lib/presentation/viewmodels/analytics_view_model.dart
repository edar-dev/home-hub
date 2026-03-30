import 'package:flutter/foundation.dart';

import '../../data/export/analytics_report_exporter.dart';
import '../../domain/entities/analytics_metrics.dart';
import '../../domain/entities/chart_data_point.dart';
import '../../domain/repositories/analytics_repository.dart';

/// Stato dashboard analytics: KPI, serie grafici, filtri periodo/luogo.
class AnalyticsViewModel extends ChangeNotifier {
  AnalyticsViewModel(this._repository) {
    final now = DateTime.now();
    _endDate = DateTime(now.year, now.month, now.day);
    _startDate = _endDate.subtract(const Duration(days: 30));
  }

  final AnalyticsRepository _repository;

  AnalyticsMetrics? _metrics;
  List<ChartDataPoint> _byLocation = [];
  List<ChartDataPoint> _topQuantity = [];
  List<ChartDataPoint> _topConsumed = [];
  List<ChartDataPoint> _recentSummary = [];
  List<ChartDataPoint> _monthlyByCategory = [];
  List<ChartDataPoint> _trend = [];

  bool _isLoading = false;
  String? _errorMessage;

  late DateTime _startDate;
  late DateTime _endDate;
  String? _selectedLocationId;

  AnalyticsMetrics? get metrics => _metrics;
  List<ChartDataPoint> get locationDistribution => List.unmodifiable(_byLocation);
  List<ChartDataPoint> get topByQuantity => List.unmodifiable(_topQuantity);
  List<ChartDataPoint> get topConsumed => List.unmodifiable(_topConsumed);
  List<ChartDataPoint> get recentConsumptionSummary =>
      List.unmodifiable(_recentSummary);
  List<ChartDataPoint> get monthlyByCategory => List.unmodifiable(_monthlyByCategory);
  List<ChartDataPoint> get consumptionTrend => List.unmodifiable(_trend);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  String? get selectedLocationId => _selectedLocationId;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadAnalytics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _metrics = await _repository.getMetrics(
        startDate: _startDate,
        endDate: _endDate,
        locationId: _selectedLocationId,
      );
      _byLocation = await _repository.getProductDistributionByLocation();
      _topQuantity = await _repository.getTopByQuantity(limit: 5);
      _topConsumed = await _repository.getTopConsumedProducts(days: 30, limit: 10);
      _recentSummary = await _repository.getRecentConsumptionSummary(days: 7);
      _monthlyByCategory = await _repository.getMonthlyConsumptionByCategory(
        month: _endDate,
      );
      _trend = await _repository.getConsumptionTrendMonths(
        months: 3,
        locationId: _selectedLocationId,
      );
    } catch (e, st) {
      debugPrint('AnalyticsViewModel.loadAnalytics: $e\n$st');
      _errorMessage = 'Impossibile caricare le statistiche';
      _metrics = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDateRange(DateTime start, DateTime end) async {
    _startDate = DateTime(start.year, start.month, start.day);
    _endDate = DateTime(end.year, end.month, end.day);
    await loadAnalytics();
  }

  Future<void> filterByLocation(String? locationId) async {
    _selectedLocationId = locationId;
    await loadAnalytics();
  }

  Future<void> exportPdf() async {
    final m = _metrics;
    if (m == null) {
      await loadAnalytics();
    }
    final mm = _metrics;
    if (mm == null) return;
    final file = await AnalyticsReportExporter.buildPdf(
      metrics: mm,
      byLocation: _byLocation,
      topQuantity: _topQuantity,
      trend: _trend,
    );
    await AnalyticsReportExporter.shareFile(file);
  }

  Future<void> exportCsv() async {
    final m = _metrics;
    if (m == null) {
      await loadAnalytics();
    }
    final mm = _metrics;
    if (mm == null) return;
    final file = await AnalyticsReportExporter.buildCsv(
      metrics: mm,
      byLocation: _byLocation,
      topQuantity: _topQuantity,
      trend: _trend,
    );
    await AnalyticsReportExporter.shareFile(file);
  }
}
