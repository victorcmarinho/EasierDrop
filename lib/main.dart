import 'package:easier_drop/helpers/system.dart';
import 'package:easier_drop/providers/files_provider.dart';
import 'package:easier_drop/screens/file_transfer_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemHelper.setup();

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
