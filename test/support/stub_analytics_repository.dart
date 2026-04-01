import 'package:housekeep/domain/entities/analytics_metrics.dart';
import 'package:housekeep/domain/repositories/analytics_repository.dart';
import 'package:mocktail/mocktail.dart';

class StubAnalyticsRepository extends Mock implements AnalyticsRepository {}

/// Repository analytics stub per test widget che montano [HousekeepApp].
StubAnalyticsRepository buildStubAnalyticsRepository() {
  final mockAnalytics = StubAnalyticsRepository();
  final now = DateTime.now();
  final start =
      DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));
  final end = DateTime(now.year, now.month, now.day);
  when(
    () => mockAnalytics.getMetrics(
      startDate: any(named: 'startDate'),
      endDate: any(named: 'endDate'),
      locationId: any(named: 'locationId'),
    ),
  ).thenAnswer(
    (_) async => AnalyticsMetrics(
      totalProducts: 0,
      expiringIn7Days: 0,
      expiredInLast30Days: 0,
      wastePercentage: 0,
      monthlyConsumptionAverage: 0,
      startDate: start,
      endDate: end,
    ),
  );
  when(() => mockAnalytics.getProductDistributionByLocation())
      .thenAnswer((_) async => []);
  when(() => mockAnalytics.getTopByQuantity(limit: any(named: 'limit')))
      .thenAnswer((_) async => []);
  when(
    () => mockAnalytics.getConsumptionTrendMonths(
      months: any(named: 'months'),
      locationId: any(named: 'locationId'),
    ),
  ).thenAnswer((_) async => []);
  when(
    () => mockAnalytics.getTopConsumedProducts(
      days: any(named: 'days'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) async => []);
  when(
    () => mockAnalytics.getRecentConsumptionSummary(
      days: any(named: 'days'),
    ),
  ).thenAnswer((_) async => []);
  when(
    () => mockAnalytics.getMonthlyConsumptionByCategory(
      month: any(named: 'month'),
    ),
  ).thenAnswer((_) async => []);
  return mockAnalytics;
}
