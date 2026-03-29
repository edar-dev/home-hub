/// Punto per grafici analytics (etichetta asse + valore numerico).
class ChartDataPoint {
  const ChartDataPoint({
    required this.label,
    required this.value,
    this.groupKey,
  });

  final String label;
  final double value;

  /// Opzionale: chiave di raggruppamento (es. id luogo).
  final String? groupKey;
}
