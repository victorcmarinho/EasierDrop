import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

class FilesProvider with ChangeNotifier {
  final List<FileReference> _files = [];

  List<FileReference> get files => _files;

  List<XFile> get xfiles {
    return _files.map((file) => XFile(file.pathname)).toList();
  }

  void addFile(FileReference file) {
    final hasValue = _files.any((f) => f.pathname == file.pathname);

    if (hasValue) return;

    _files.add(file);
    notifyListeners();
  }

  void addAllFiles(List<FileReference> files) {
    final diference = _getDifference(files);

    if (diference.isNotEmpty) {
      _files.addAll(files);
      notifyListeners();
    }
  }

  List<FileReference> _getDifference(List<FileReference> files) {
    final List<FileReference> difference = [];
    for (final file in files) {
      if (!_files.any((f) => f.pathname == file.pathname)) {
        difference.add(file);
      }
    }
    return difference;
  }

  void removeFile(FileReference file) {
    _files.remove(file);
    notifyListeners();
  }

  void clear() {
    _files.clear();
    notifyListeners();
  }

  Future<Object> shared({Offset? position}) async {
    if (xfiles.isEmpty) {
      return ShareResult(
        "Sem arquivos para compartilhar",
        ShareResultStatus.unavailable,
      );
    }

    final params = ShareParams(
      files: xfiles,
      sharePositionOrigin:
          position != null
              ? Rect.fromLTRB(
                position.dx,
                position.dy,
                position.dx + 40,
                position.dy + 40,
              )
              : null,
    );

    return SharePlus.instance.share(params);
  }
}
