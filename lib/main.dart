import 'package:flutter/foundation.dart';
import 'package:easier_drop/main.web.dart' as web_main;
import 'package:easier_drop/main.macos.dart' as macos_main;

Future<void> main(List<String> args) async {
  if (kIsWeb) {
    await web_main.main();
  } else {
    await macos_main.main(args);
  }
}
