import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/screens/file_transfer_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureWindow();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => FilesProvider())],
      child: const EasierDrop(),
    ),
  );
}

Future<void> _configureWindow() async {
  await windowManager.ensureInitialized();

  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      minimumSize: Size(150, 150),
      size: Size(250, 250),
      backgroundColor: Colors.transparent,
      alwaysOnTop: true,
      titleBarStyle: TitleBarStyle.hidden,
      title: 'Easier Drop',
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );
}

class EasierDrop extends StatelessWidget {
  const EasierDrop({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easier Drop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const FileTransferScreen(),
    );
  }
}
