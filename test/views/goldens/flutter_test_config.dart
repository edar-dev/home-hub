import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Consente piccole differenze di rendering tra host (es. Windows in dev vs macOS su Codemagic).
const double _kGoldenDiffTolerance = 0.03;

class _TolerantGoldenFileComparator extends LocalFileComparator {
  _TolerantGoldenFileComparator(super.testFile, {required this.tolerance});

  final double tolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    final ok = result.passed || result.diffPercent <= tolerance;
    if (ok) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final anchor = p.join(
    Directory.current.path,
    'test',
    'views',
    'goldens',
    'onboarding_golden_test.dart',
  );
  goldenFileComparator = _TolerantGoldenFileComparator(
    Uri.file(anchor),
    tolerance: _kGoldenDiffTolerance,
  );
  await testMain();
}
