import 'package:easier_drop/helpers/macos/file_icon_helper.dart';
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

      // Fetch icon after adding the file to update the UI with the icon
      final iconData = await FileIconHelper.getFileIcon(file.pathname);
      if (iconData != null) {
        final fileWithIcon = FileReference(
          pathname: file.pathname,
          iconData: iconData,
        );
        // Replace the file reference in the set
        _files.remove(file);
        _files.add(fileWithIcon);
        notifyListeners();
      }

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

      final addedFiles = newFiles.where((file) => _files.add(file)).toList();

      if (addedFiles.isNotEmpty) {
        notifyListeners();
        debugPrint('${addedFiles.length} arquivos adicionados');

        // Fetch icons for all new files
        await Future.wait(
          addedFiles.map((file) async {
            final iconData = await FileIconHelper.getFileIcon(file.pathname);
            if (iconData != null) {
              final updatedFile = FileReference(
                pathname: file.pathname,
                iconData: iconData,
              );
              _files.remove(file);
              _files.add(updatedFile);
            }
          }),
        );
        notifyListeners();
      } else {
        debugPrint('Nenhum arquivo novo para adicionar');
      }
    } catch (e) {
      debugPrint('Erro ao adicionar arquivos: $e');
    }
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

  void removeByPath(String pathname) {
    try {
      final file = _files.firstWhere(
        (file) => file.pathname == pathname,
        orElse: () => throw Exception('Arquivo não encontrado'),
      );

      _files.remove(file);
      notifyListeners();
      debugPrint('Arquivo removido: $pathname');
    } catch (e) {
      debugPrint('Erro ao remover arquivo por path: $e');
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
