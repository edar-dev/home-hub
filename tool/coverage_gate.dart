// Controlla line coverage da coverage/lcov.info escludendo *.g.dart (e opz. main.dart).
// Uso: dopo `flutter test --coverage` (escludere integration_test se non serve nel gate),
// eseguire `dart run tool/coverage_gate.dart`
//
// Memoria / DevTools: vedi tool/testing_and_debug.md (sezione performance).

import 'dart:io';

const double minLineCoverage = 0.80;

void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    stderr.writeln('Manca coverage/lcov.info. Esegui: flutter test --coverage');
    exit(1);
  }
  final text = file.readAsStringSync();
  var lf = 0;
  var lh = 0;

  for (final block in text.split('end_of_record')) {
    if (block.trim().isEmpty) continue;
    String? sourcePath;
    var blockLf = 0;
    var blockLh = 0;
    for (final line in block.split('\n')) {
      if (line.startsWith('SF:')) {
        sourcePath = line.substring(3).trim();
      } else if (line.startsWith('LF:')) {
        blockLf += int.tryParse(line.substring(3).trim()) ?? 0;
      } else if (line.startsWith('LH:')) {
        blockLh += int.tryParse(line.substring(3).trim()) ?? 0;
      }
    }
    if (sourcePath == null) continue;
    final normalized = sourcePath.replaceAll(r'\', '/');
    if (normalized.contains('.g.dart')) continue;
    if (normalized.endsWith('lib/main.dart')) continue;
    lf += blockLf;
    lh += blockLh;
  }

  if (lf == 0) {
    stderr.writeln('Nessuna linea coperta dopo filtri.');
    exit(1);
  }

  final ratio = lh / lf;
  final pct = (ratio * 100).toStringAsFixed(2);
  stdout.writeln(
      'Line coverage (escl. *.g.dart, lib/main.dart): $pct% ($lh/$lf)');

  if (ratio + 1e-9 < minLineCoverage) {
    stderr.writeln(
        'Sotto la soglia minima ${(minLineCoverage * 100).toStringAsFixed(0)}%.');
    exit(1);
  }
}
