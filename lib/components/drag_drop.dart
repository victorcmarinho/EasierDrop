import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
// window_manager não necessário aqui (usado no WindowHandle)
import 'window_handle.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/controllers/drag_coordinator.dart';
import 'parts/files_surface.dart';

class DragDrop extends StatefulWidget {
  const DragDrop({super.key});

  @override
  State<DragDrop> createState() => _DragDropState();
}

class _DragDropState extends State<DragDrop> {
  final GlobalKey _buttonKey = GlobalKey();
  static const double _handleGestureHeight = 28.0;
  late DragCoordinator _coordinator;

  @override
  void initState() {
    super.initState();
    _coordinator = DragCoordinator(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => _coordinator.init());
  }

  @override
  void dispose() {
    _coordinator.dispose();
    super.dispose();
  }

  Offset? _getButtonPosition() {
    final RenderBox? renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.localToGlobal(Offset.zero);
  }

  void _clearImmediate(FilesProvider provider) {
    if (provider.files.isEmpty) return;
    provider.clear();
  }

  @override
  Widget build(BuildContext context) {
    final filesProvider = context.read<FilesProvider>();
    final hasFiles = context.select<FilesProvider, bool>(
      (p) => p.files.isNotEmpty,
    );
    final limitHitAt = context.select<FilesProvider, DateTime?>(
      (p) => p.lastLimitHit,
    );
    final showLimit =
        limitHitAt != null &&
        DateTime.now().difference(limitHitAt) < const Duration(seconds: 2);
    final loc = AppLocalizations.of(context)!;

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Stack(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _coordinator.hovering,
            builder:
                (context, hovering, _) => ValueListenableBuilder<bool>(
                  valueListenable: _coordinator.draggingOut,
                  builder:
                      (context, draggingOut, _) => FilesSurface(
                        hovering: hovering,
                        draggingOut: draggingOut,
                        showLimit: showLimit,
                        hasFiles: hasFiles,
                        buttonKey: _buttonKey,
                        loc: loc,
                        onHoverChanged: _coordinator.setHover,
                        onDragCheck: (dy) => dy > _handleGestureHeight,
                        onDragRequest: _coordinator.beginExternalDrag,
                        onClear: () => _clearImmediate(filesProvider),
                        getButtonPosition: _getButtonPosition,
                        filesProvider: filesProvider,
                      ),
                ),
          ),
          const WindowHandle(),
        ],
      ),
    );
  }
}
