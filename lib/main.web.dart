import 'package:flutter/material.dart';
import 'package:easier_drop/web/website_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WebsiteApp());
}
