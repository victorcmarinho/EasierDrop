import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/screens/file_transfer_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(250, 250),
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    fullScreen: false,
    alwaysOnTop: true,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Easier Drop',
    minimumSize: Size(150, 150),
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => FilesProvider())],
      child: const EasierDrop(),
    ),
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
