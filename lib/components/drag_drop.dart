import 'dart:async';
import 'package:easier_drop/components/drop_hit.dart';
import 'package:easier_drop/components/files_stack.dart';
import 'package:easier_drop/components/remove_button.dart';
import 'package:easier_drop/components/share_button.dart';
import 'package:easier_drop/helpers/system.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DragDrop extends StatefulWidget {
  const DragDrop({super.key});

  @override
  State<DragDrop> createState() => _DragDropState();
}

class _DragDropState extends State<DragDrop> {
  final GlobalKey _buttonKey = GlobalKey();

  StreamSubscription? _dropDestinationSubscription;

  @override
  void initState() {
    super.initState();
    _setupMethodCallHandler();
    _startDragMonitor();
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    _dropDestinationSubscription?.cancel();
    _stopDragMonitor();
    super.dispose();
  }

  Future<void> _startDragMonitor() async {
    try {
      await _channel.invokeMethod('startDropMonitor');

      // Configura o listener para eventos de drop
      final eventChannel = const EventChannel('file_drop_channel/events');
      _dropDestinationSubscription = eventChannel
          .receiveBroadcastStream()
          .listen((dynamic event) async {
            if (event is List) {
              final files = List<String>.from(event);
              debugPrint('[DragDrop] ⭐️ Arquivos recebidos: $files');
              for (final path in files) {
                final extension = path.split('.').last.toLowerCase();
                final icon = await FileReference.getCachedIcon(extension, path);
                final fileRef = FileReference(iconData: icon, pathname: path);
                if (mounted) {
                  context.read<FilesProvider>().addFile(fileRef);
                }
              }
            }
          });
    } catch (e) {
      debugPrint('❌ Erro ao iniciar monitor de drag: $e');
    }
  }

  Future<void> _stopDragMonitor() async {
    try {
      await _channel.invokeMethod('stopDropMonitor');
    } catch (e) {
      debugPrint('❌ Erro ao parar monitor de drag: $e');
    }
  }

  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'fileDropped') {
        final path = call.arguments as String;
        debugPrint('✅ Arquivo movido com sucesso para: $path');

        // Remove o arquivo da lista depois de movê-lo
        final filesProvider = context.read<FilesProvider>();
        filesProvider.clear();
      }
      return null;
    });
  }

  Offset? _getButtonPosition() {
    final RenderBox? renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.localToGlobal(Offset.zero);
  }

  Widget _buildAnimatedButton({required bool visible, required Widget child}) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: visible ? 1.0 : 0.0,
      child: visible ? child : const SizedBox(width: 40, height: 40),
    );
  }

  final _channel = const MethodChannel('file_drop_channel');

  Future<void> _handleDragOut() async {
    debugPrint("🔄 Iniciando operação de drag para fora do app");
    final filesProvider = context.read<FilesProvider>();
    final files = filesProvider.files.map((f) => f.pathname).toList();

    try {
      await _channel.invokeMethod('beginDrag', {'items': files});
      debugPrint('✅ Operação de drag iniciada com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao iniciar drag: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filesProvider = context.watch<FilesProvider>();
    final hasFiles = filesProvider.files.isNotEmpty;

    return GestureDetector(
      onPanStart: (_) => _handleDragOut(),
      child: Container(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            hasFiles
                ? FilesStack(droppedFiles: filesProvider.files)
                : const DropHit(),

            Positioned(
              left: 0,
              top: 0,
              child: CloseButton(onPressed: () => SystemHelper.hide()),
            ),

            Positioned(
              right: 0,
              top: 0,
              child: _buildAnimatedButton(
                visible: hasFiles,
                child: ShareButton(
                  key: _buttonKey,
                  onPressed:
                      () =>
                          filesProvider.shared(position: _getButtonPosition()),
                ),
              ),
            ),

            Positioned(
              right: 0,
              bottom: 0,
              child: _buildAnimatedButton(
                visible: hasFiles,
                child: RemoveButton(onPressed: filesProvider.clear),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
