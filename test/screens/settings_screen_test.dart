import 'package:easier_drop/screens/settings_screen.dart';
import 'package:easier_drop/services/settings_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class MockPathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String> getApplicationSupportPath() async {
    return '.';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannel shakeChannel;
  late MethodChannel launchChannel;

  setUpAll(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  setUp(() {
    shakeChannel = const MethodChannel('com.easier_drop/shake');
    launchChannel = const MethodChannel('com.easierdrop/launch_at_login');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(shakeChannel, (MethodCall methodCall) async {
          if (methodCall.method == 'checkPermission') {
            return true;
          }
          return null;
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(launchChannel, (MethodCall methodCall) async {
          if (methodCall.method == 'checkPermission') {
            return true;
          }
          return null;
        });

    SettingsService.instance.resetForTesting();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(shakeChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(launchChannel, null);
  });

  Widget createWidgetUnderTest() {
    return MacosApp(
      theme: MacosThemeData.light(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      home: const SettingsScreen(),
    );
  }

  testWidgets('SettingsScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Preferences'), findsOneWidget);

    expect(find.text('GENERAL'), findsOneWidget);
    expect(find.text('SHAKE GESTURE'), findsOneWidget);
    expect(find.text('LANGUAGE:'), findsOneWidget);

    expect(find.text('Launch at Login'), findsOneWidget);
    expect(find.text('Always on Top'), findsOneWidget);
    expect(find.text('Shake Gesture'), findsOneWidget);

    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('SettingsScreen handles missing permission', (
    WidgetTester tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(shakeChannel, (MethodCall methodCall) async {
          if (methodCall.method == 'checkPermission') {
            return false;
          }
          return null;
        });

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Inactive'), findsOneWidget);
  });
}
