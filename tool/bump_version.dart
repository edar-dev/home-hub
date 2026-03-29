// Bump pubspec.yaml version. Usage from repo root:
//   dart run tool/bump_version.dart [build|patch|minor|major]
//
// Format: MAJOR.MINOR.PATCH+BUILD (Flutter: name+code).

import 'dart:io';

void main(List<String> args) {
  final mode = args.isEmpty ? 'build' : args.first;
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    stderr.writeln('Run from repository root (pubspec.yaml not found).');
    exitCode = 1;
    return;
  }

  var content = pubspec.readAsStringSync();
  final re = RegExp(r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$', multiLine: true);
  final m = re.firstMatch(content);
  if (m == null) {
    stderr.writeln('Could not parse version: line must be like version: 1.0.0+1');
    exitCode = 1;
    return;
  }

  var major = int.parse(m.group(1)!);
  var minor = int.parse(m.group(2)!);
  var patch = int.parse(m.group(3)!);
  var build = int.parse(m.group(4)!);

  switch (mode) {
    case 'build':
      build += 1;
    case 'patch':
      patch += 1;
      build = 1;
    case 'minor':
      minor += 1;
      patch = 0;
      build = 1;
    case 'major':
      major += 1;
      minor = 0;
      patch = 0;
      build = 1;
    default:
      stderr.writeln('Unknown mode "$mode". Use: build, patch, minor, major');
      exitCode = 1;
      return;
  }

  final newLine = 'version: $major.$minor.$patch+$build';
  content = content.replaceFirst(re, newLine);
  pubspec.writeAsStringSync(content);
  stdout.writeln(newLine);
}
