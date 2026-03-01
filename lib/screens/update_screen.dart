import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:easier_drop/services/update_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  bool _isLoading = true;
  String? _updateUrl;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupWindow();
    _checkForUpdates();
  }

  Future<void> _setupWindow() async {
    await windowManager.ensureInitialized();
    await windowManager.setAlwaysOnTop(true);
  }

  Future<void> _closeWindow() async {
    await windowManager.close();
  }

  Future<void> _checkForUpdates() async {
    try {
      final url = await UpdateService.instance.checkForUpdates();
      if (mounted) {
        setState(() {
          _updateUrl = url;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: const ToolBar(
        title: Text('Software Update'),
        titleWidth: 150.0,
        automaticallyImplyLeading: false,
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildContent(context),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ProgressCircle(),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.checkingForUpdates),
        ],
      );
    }

    if (_errorMessage != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MacosIcon(
            CupertinoIcons.exclamationmark_triangle,
            size: 48,
            color: CupertinoColors.systemRed,
          ),
          const SizedBox(height: 16),
          Text(_errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          PushButton(
            controlSize: ControlSize.large,
            onPressed: _closeWindow,
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      );
    }

    if (_updateUrl != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MacosIcon(
            CupertinoIcons.arrow_down_circle,
            size: 48,
            color: CupertinoColors.activeBlue,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.updateAvailable,
            style: MacosTheme.of(context).typography.title1,
          ),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)!.updateAvailableMessage),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PushButton(
                controlSize: ControlSize.large,
                secondary: true,
                onPressed: _closeWindow,
                child: Text(AppLocalizations.of(context)!.later),
              ),
              const SizedBox(width: 16),
              PushButton(
                controlSize: ControlSize.large,
                onPressed: () {
                  launchUrl(Uri.parse(_updateUrl!));
                  _closeWindow();
                },
                child: Text(AppLocalizations.of(context)!.download),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const MacosIcon(
          CupertinoIcons.checkmark_circle,
          size: 48,
          color: CupertinoColors.systemGreen,
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.noUpdatesAvailable,
          style: MacosTheme.of(context).typography.title2,
        ),
        const SizedBox(height: 24),
        PushButton(
          controlSize: ControlSize.large,
          onPressed: _closeWindow,
          child: Text('OK'),
        ),
      ],
    );
  }
}
