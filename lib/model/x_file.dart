import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class XFile {
  final Uint8List? iconData;
  final String pathname;
  final File file;

  XFile({this.iconData, required this.pathname, required this.file});
}
