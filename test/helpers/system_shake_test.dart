import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easier_drop/services/analytics_service.dart';
import 'package:easier_drop/helpers/app_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock Channel
  const MethodChannel channel = MethodChannel(AppConstants.shakeChannelName);
  final List<MethodCall> log = <MethodCall>[];

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        });

    // Initialize Analytics for logging
    await AnalyticsService.instance.initialize();
  });

  tearDown(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  // Note: We cannot easily test the private _handleShakeEvent directly without Reflection
  // or making it public. However, we can verifying the SystemHelper initialization
  // sets up the handler.

  // Ideally, valid testing of private static methods requires refactoring or
  // integration testing. For now, this test file serves as a placeholder
  // and a location to manually verify behavior if we were to expose the method.

  test('Sanity check - Analytics is initialized', () {
    expect(AnalyticsService.instance, isNotNull);
  });
}
