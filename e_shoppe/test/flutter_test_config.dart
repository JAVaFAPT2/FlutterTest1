// Test-time stub to avoid file_picker plugin registration errors.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Global test bootstrap. Executed before any test file.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Stub file_picker method channel to avoid plugin registration errors.
  const channel = MethodChannel('plugins.flutter.io/file_picker');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async => null);

  await testMain();
}
