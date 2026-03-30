class ConsumptionStats {
  const ConsumptionStats({
    required this.totalConsumed,
    required this.avgDailyConsumption,
    required this.avgWeeklyConsumption,
    required this.daysRemainingEstimate,
    required this.lastConsumptionDate,
    required this.isAlmostEmpty,
  });

  final double totalConsumed;
  final double avgDailyConsumption;
  final double avgWeeklyConsumption;
  final double? daysRemainingEstimate;
  final DateTime? lastConsumptionDate;
  final bool isAlmostEmpty;
}
