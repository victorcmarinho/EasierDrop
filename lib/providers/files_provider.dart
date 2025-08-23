import 'package:easier_drop/model/file_reference.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

class FilesProvider with ChangeNotifier {
  final List<FileReference> _files = [];
  static const int _maxFiles = 100; // Limite de arquivos

  List<FileReference> get files => List.unmodifiable(_files);

  List<XFile> get xfiles {
    return _files
        .where((file) => file.isValid())
        .map((file) => XFile(file.pathname))
        .toList();
  }

  Future<void> addFile(FileReference file) async {
    try {
      if (!file.isValid()) {
        debugPrint('Arquivo inválido: ${file.pathname}');
        return;
      }

      if (_files.length >= _maxFiles) {
        debugPrint('Limite de arquivos atingido');
        return;
      }

      final hasValue = _files.contains(file);
      if (hasValue) {
        debugPrint('Arquivo já existe: ${file.pathname}');
        return;
      }

      _files.add(file);
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

      final validFiles = files.where((file) => file.isValid()).toList();
      if (validFiles.isEmpty) {
        debugPrint('Nenhum arquivo válido para adicionar');
        return;
      }

      final difference = _getDifference(validFiles);
      if (difference.isEmpty) {
        debugPrint('Nenhum arquivo novo para adicionar');
        return;
      }

      _files.addAll(difference);
      notifyListeners();

      debugPrint('${difference.length} arquivos adicionados');
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
