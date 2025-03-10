import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class FileReference {
  final Uint8List? iconData;
  final String pathname;

  FileReference({this.iconData, required this.pathname});
}
