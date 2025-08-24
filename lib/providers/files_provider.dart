import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

class FilesProvider with ChangeNotifier {
  final Set<FileReference> _files = {};
  static const int _maxFiles = 100; // Limite de arquivos

  List<FileReference> get files => _files.toList();

  List<XFile> get xfiles {
    return _files
        .where((file) => file.isValid())
        .map((file) => XFile(file.pathname))
        .toList();
  }

  Future<void> addFile(FileReference file) async {
    try {
      if (!await file.isValidAsync()) {
        debugPrint('Arquivo inválido: ${file.pathname}');
        return;
      }

      if (_files.length >= _maxFiles) {
        debugPrint('Limite de arquivos atingido');
        return;
      }

      if (!_files.add(file)) {
        debugPrint('Arquivo já existe: ${file.pathname}');
        return;
      }

      notifyListeners();

      final fileSize = await file.size;
      debugPrint('Arquivo adicionado: ${file.fileName} (${fileSize} bytes)');
    } catch (e) {
      debugPrint('Erro ao adicionar arquivo: $e');
    }
  }

  Future<void> addAllFiles(List<FileReference> files) async {
    try {
      if (_files.length + files.length > _maxFiles) {
        debugPrint('Limite de arquivos seria excedido');
        return;
      }

      final validFiles = await Future.wait(
        files.map((file) async {
          if (await file.isValidAsync()) return file;
          return null;
        }),
      );

      final newFiles = validFiles.whereType<FileReference>().toList();
      if (newFiles.isEmpty) {
        debugPrint('Nenhum arquivo válido para adicionar');
        return;
      }

      final addedCount = newFiles.where(_files.add).length;
      if (addedCount > 0) {
        notifyListeners();
        debugPrint('$addedCount arquivos adicionados');
      } else {
        debugPrint('Nenhum arquivo novo para adicionar');
      }
    } catch (e) {
      debugPrint('Erro ao adicionar arquivos: $e');
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

  Future<void> removeFile(FileReference file) async {
    try {
      if (!_files.contains(file)) {
        debugPrint('Arquivo não encontrado para remoção: ${file.pathname}');
        return;
      }

      _files.remove(file);
      notifyListeners();
      debugPrint('Arquivo removido: ${file.fileName}');
    } catch (e) {
      debugPrint('Erro ao remover arquivo: $e');
    }
  }

  void clear() {
    try {
      final count = _files.length;
      _files.clear();
      notifyListeners();
      debugPrint('$count arquivos removidos');
    } catch (e) {
      debugPrint('Erro ao limpar arquivos: $e');
    }
  }

  Future<Object> shared({Offset? position}) async {
    try {
      final validFiles = xfiles;

      if (validFiles.isEmpty) {
        debugPrint('Nenhum arquivo válido para compartilhar');
        return ShareResult(
          "Sem arquivos para compartilhar",
          ShareResultStatus.unavailable,
        );
      }

      final params = ShareParams(
        files: validFiles,
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

      debugPrint('Compartilhando ${validFiles.length} arquivos');
      return SharePlus.instance.share(params);
    } catch (e) {
      debugPrint('Erro ao compartilhar arquivos: $e');
      return ShareResult(
        "Erro ao compartilhar arquivos",
        ShareResultStatus.unavailable,
      );
    }
  }
}
