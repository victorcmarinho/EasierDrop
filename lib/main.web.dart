import 'package:flutter/widgets.dart';
import 'package:easier_drop/web/website_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WebsiteApp());
}
