import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:easier_drop/controllers/drag_coordinator.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/services/constants.dart';
import 'package:easier_drop/services/file_drop_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DragCoordinator extended', () {
    late List<MethodCall> fileDropCalls;
    late List<MethodCall> dragOutCalls;
    late StreamController<List<String>> eventController;

    setUp(() {
      fileDropCalls = [];
      dragOutCalls = [];
      eventController = StreamController<List<String>>();

      // Mock file drop method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(PlatformChannels.fileDrop),
            (call) async {
              fileDropCalls.add(call);
              return null;
            },
          );
      // Mock event channel broadcast
      ServicesBinding.instance.channelBuffers.push(
        const EventChannel(PlatformChannels.fileDropEvents).name,
        const StandardMethodCodec().encodeSuccessEnvelope(null),
        (ByteData? data) {},
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(PlatformChannels.fileDropEvents, (
            message,
          ) async {
            return const StandardMethodCodec().encodeSuccessEnvelope(null);
          });

      // Mock drag out channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(PlatformChannels.fileDragOut),
            (call) async {
              dragOutCalls.add(call);
              return null;
            },
          );
    });

    tearDown(() async {
      eventController.close();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(PlatformChannels.fileDrop),
            null,
          );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel(PlatformChannels.fileDragOut),
            null,
          );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(PlatformChannels.fileDropEvents, null);
    });

    Future<DragCoordinator> _build(
      WidgetTester tester,
      FilesProvider provider,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [ChangeNotifierProvider.value(value: provider)],
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(width: 10, height: 10),
          ),
        ),
      );
      final ctx = tester.element(find.byType(SizedBox));
      return DragCoordinator(ctx);
    }

    testWidgets('init starts monitoring and receives file events', (
      tester,
    ) async {
      final provider = FilesProvider(enableMonitoring: false);
      final coord = await _build(tester, provider);
      await coord.init();
      expect(FileDropService.instance.isMonitoring, isTrue);

      // Simula evento de arquivos via EventChannel: enviar mensagem manual com lista
      final eventChannelName = PlatformChannels.fileDropEvents;
      final codec = const StandardMethodCodec();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            eventChannelName,
            codec.encodeSuccessEnvelope(['fileA', 'fileB']),
            (_) {},
          );
      await tester.pump(const Duration(milliseconds: 10));
      expect(provider.files.length, 2);
    });

    testWidgets(
      'beginExternalDrag toggles draggingOut and retains files on copy op',
      (tester) async {
        final provider = FilesProvider(enableMonitoring: false);
        provider.addFileForTest(const FileReference(pathname: '/tmp/drag.txt'));
        await tester.pump();
        final coord = await _build(tester, provider);
        // Simular que init já configurou handlers (não precisamos iniciar monitor aqui)
        await coord.beginExternalDrag();
        expect(coord.draggingOut.value, isTrue);
        // Simula retorno de drag copy
        coord.handleOutboundTest({'status': 'ok', 'op': 'copy'});
        await tester.pump(const Duration(milliseconds: 450));
        expect(coord.draggingOut.value, isFalse);
        expect(provider.files.length, 1, reason: 'Copy should retain');
      },
    );

    testWidgets('beginExternalDrag clears files on move', (tester) async {
      final provider = FilesProvider(enableMonitoring: false);
      provider.addFileForTest(const FileReference(pathname: '/tmp/move.txt'));
      await tester.pump();
      final coord = await _build(tester, provider);
      await coord.beginExternalDrag();
      coord.handleOutboundTest({'status': 'ok', 'op': 'move'});
      await tester.pump();
      expect(provider.files, isEmpty);
    });

    testWidgets('beginExternalDrag with no files does nothing', (tester) async {
      final provider = FilesProvider(enableMonitoring: false);
      final coord = await _build(tester, provider);
      await coord.beginExternalDrag();
      expect(coord.draggingOut.value, isFalse);
    });

    testWidgets('unknown operation retains files', (tester) async {
      final provider = FilesProvider(enableMonitoring: false);
      provider.addFileForTest(
        const FileReference(pathname: '/tmp/unknown.txt'),
      );
      await tester.pump();
      final coord = await _build(tester, provider);
      await coord.beginExternalDrag();
      coord.handleOutboundTest({'status': 'ok', 'op': 'zzz'});
      await tester.pump();
      expect(provider.files.length, 1);
    });

    testWidgets('setHover updates notifier', (tester) async {
      final provider = FilesProvider(enableMonitoring: false);
      final coord = await _build(tester, provider);
      expect(coord.hovering.value, isFalse);
      coord.setHover(true);
      expect(coord.hovering.value, isTrue);
    });
  });
}
