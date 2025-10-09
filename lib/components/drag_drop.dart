import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'window_handle.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/controllers/drag_coordinator.dart';
import 'package:easier_drop/helpers/app_constants.dart';
import 'parts/files_surface.dart';

class DragDrop extends StatefulWidget {
  const DragDrop({super.key});

  @override
  State<DragDrop> createState() => _DragDropState();
}

class _DragDropState extends State<DragDrop> {
  final GlobalKey _shareButtonKey = GlobalKey();
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

  Offset? _getShareButtonPosition() {
    final RenderBox? renderBox =
        _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.localToGlobal(Offset.zero);
  }

  void _clearFiles(FilesProvider provider) {
    if (provider.hasFiles) {
      provider.clear();
    }
  }

  bool _isDragArea(double dy) => dy > AppConstants.windowHandleHeight;

  @override
  Widget build(BuildContext context) {
    final filesProvider = context.read<FilesProvider>();
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
                      (context, draggingOut, _) => Consumer<FilesProvider>(
                        builder:
                            (context, provider, _) => FilesSurface(
                              hovering: hovering,
                              draggingOut: draggingOut,
                              showLimit: provider.recentlyAtLimit,
                              hasFiles: provider.hasFiles,
                              buttonKey: _shareButtonKey,
                              loc: loc,
                              onHoverChanged: _coordinator.setHover,
                              onDragCheck: _isDragArea,
                              onDragRequest: _coordinator.beginExternalDrag,
                              onClear: () => _clearFiles(filesProvider),
                              getButtonPosition: _getShareButtonPosition,
                              filesProvider: filesProvider,
                            ),
                      ),
                ),
          ),
          const WindowHandle(),
        ],
      ),
    );
  }
}
