// Test-time stub to avoid file_picker plugin registration errors.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Global test bootstrap. Executed before any test file.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Stub file_picker method channel to avoid plugin registration errors.
  const MethodChannel('plugins.flutter.io/file_picker')
      .setMockMethodCallHandler((_) async => null);

  await testMain();
}
