import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/brand/app_brand.dart';
import '../../domain/entities/analytics_metrics.dart';
import '../../domain/entities/chart_data_point.dart';

/// Export PDF/CSV per dashboard analytics (file temporaneo + [Share.shareXFiles]).
abstract final class AnalyticsReportExporter {
  static Future<File> buildPdf({
    required AnalyticsMetrics metrics,
    required List<ChartDataPoint> byLocation,
    required List<ChartDataPoint> topQuantity,
    required List<ChartDataPoint> trend,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            text: '${AppBrand.appNameDisplay} — Report analytics',
          ),
          pw.Text(
            'Periodo: ${metrics.startDate.toIso8601String().split('T').first} — '
            '${metrics.endDate.toIso8601String().split('T').first}',
          ),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: const ['Metrica', 'Valore'],
            data: <List<String>>[
              <String>['Prodotti totali', '${metrics.totalProducts}'],
              <String>['In scadenza (7 giorni)', '${metrics.expiringIn7Days}'],
              <String>['Scaduti (ultimi 30 gg)', '${metrics.expiredInLast30Days}'],
              <String>['Sprechi %', metrics.wastePercentage.toStringAsFixed(1)],
              <String>[
                'Consumo medio mensile (stima)',
                metrics.monthlyConsumptionAverage.toStringAsFixed(1),
              ],
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Distribuzione per luogo',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          ...byLocation.map(
            (e) => pw.Text('${e.label}: ${e.value.toStringAsFixed(0)}'),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Top per quantità',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          ...topQuantity.map(
            (e) => pw.Text('${e.label}: ${e.value.toStringAsFixed(0)}'),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Trend mensile (stima)',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          ...trend.map(
            (e) => pw.Text('${e.label}: ${e.value.toStringAsFixed(1)}'),
          ),
        ],
      ),
    );
    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'housekeep_analytics.pdf'));
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<File> buildCsv({
    required AnalyticsMetrics metrics,
    required List<ChartDataPoint> byLocation,
    required List<ChartDataPoint> topQuantity,
    required List<ChartDataPoint> trend,
  }) async {
    final buf = StringBuffer()
      ..writeln('metric,value')
      ..writeln('totalProducts,${metrics.totalProducts}')
      ..writeln('expiringIn7Days,${metrics.expiringIn7Days}')
      ..writeln('expiredInLast30Days,${metrics.expiredInLast30Days}')
      ..writeln('wastePercentage,${metrics.wastePercentage}')
      ..writeln('monthlyConsumptionAverage,${metrics.monthlyConsumptionAverage}')
      ..writeln()
      ..writeln('location,count');
    for (final e in byLocation) {
      buf.writeln('"${e.label}",${e.value}');
    }
    buf.writeln('product,quantityRemaining');
    for (final e in topQuantity) {
      buf.writeln('"${e.label}",${e.value}');
    }
    buf.writeln('month,trendEstimate');
    for (final e in trend) {
      buf.writeln('"${e.label}",${e.value}');
    }
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'housekeep_analytics.csv'));
    await file.writeAsString(buf.toString());
    return file;
  }

  static Future<void> shareFile(File file) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Export ${AppBrand.appNameDisplay}',
    );
  }
}
