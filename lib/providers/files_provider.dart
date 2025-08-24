import 'dart:async';
import 'package:easier_drop/helpers/macos/file_icon_helper.dart';
import 'package:easier_drop/model/file_reference.dart';
import 'package:easier_drop/services/logger.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

/// Provider responsável apenas por gerenciar o estado (coleção de arquivos) e
/// disparar notificações. Regras de ícone e validação simples permanecem aqui
/// dado o pequeno escopo do app.
class FilesProvider with ChangeNotifier {
  // Mantém ordem de inserção determinística
  final Map<String, FileReference> _files = {};
  static const int _maxFiles = 100; // Limite de arquivos

  List<FileReference> get files => _files.values.toList(growable: false);

  List<XFile> get xfiles => _files.values
      .where((f) => f.isValidSync())
      .map((f) => XFile(f.pathname))
      .toList(growable: false);

  bool get isEmpty => _files.isEmpty;

  Timer? _debounce;
  void _scheduleNotify() {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 40),
      () => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> addFile(FileReference file) async {
    try {
      if (_files.length >= _maxFiles) {
        AppLogger.warn('Limite de arquivos atingido', tag: 'FilesProvider');
        return;
      }
      if (!await file.isValidAsync()) {
        AppLogger.debug(
          'Arquivo inválido: ${file.pathname}',
          tag: 'FilesProvider',
        );
        return;
      }
      if (_files.containsKey(file.pathname)) {
        AppLogger.debug(
          'Arquivo já existe: ${file.pathname}',
          tag: 'FilesProvider',
        );
        return;
      }

      _files[file.pathname] = file;
      _scheduleNotify();

      // Busca ícone (não bloqueia primeira pintura do item)
      final iconData = await FileIconHelper.getFileIcon(file.pathname);
      if (iconData != null) {
        final current = _files[file.pathname];
        if (current != null && current.iconData == null) {
          _files[file.pathname] = current.withIcon(iconData);
          _scheduleNotify();
        }
      }
      final size = await file.size;
      AppLogger.info(
        'Arquivo adicionado: ${file.fileName} (${size} bytes)',
        tag: 'FilesProvider',
      );
    } catch (e) {
      AppLogger.error('Erro ao adicionar arquivo: $e', tag: 'FilesProvider');
    }
  }

  Future<void> addAllFiles(List<FileReference> files) async {
    try {
      if (_files.length >= _maxFiles) return;
      for (final file in files) {
        if (_files.length >= _maxFiles) break;
        if (_files.containsKey(file.pathname)) continue;
        if (!await file.isValidAsync()) continue;
        _files[file.pathname] = file;
      }
      _scheduleNotify();

      // Carrega ícones em paralelo para novos arquivos que ainda não têm ícone
      await Future.wait(
        _files.values.where((f) => f.iconData == null).map((f) async {
          final icon = await FileIconHelper.getFileIcon(f.pathname);
          if (icon != null) {
            final current = _files[f.pathname];
            if (current != null && current.iconData == null) {
              _files[f.pathname] = current.withIcon(icon);
            }
          }
        }),
      );
      _scheduleNotify();
    } catch (e) {
      AppLogger.error('Erro ao adicionar arquivos: $e', tag: 'FilesProvider');
    }
  }

  Future<void> removeFile(FileReference file) async {
    try {
      if (_files.remove(file.pathname) != null) {
        _scheduleNotify();
        AppLogger.info(
          'Arquivo removido: ${file.fileName}',
          tag: 'FilesProvider',
        );
      }
    } catch (e) {
      AppLogger.error('Erro ao remover arquivo: $e', tag: 'FilesProvider');
    }
  }

  void removeByPath(String pathname) {
    try {
      if (_files.remove(pathname) != null) {
        _scheduleNotify();
        AppLogger.info('Arquivo removido: $pathname', tag: 'FilesProvider');
      }
    } catch (e) {
      AppLogger.error(
        'Erro ao remover arquivo por path: $e',
        tag: 'FilesProvider',
      );
    }
  }

  void clear() {
    final count = _files.length;
    _files.clear();
    _scheduleNotify();
    AppLogger.info('$count arquivos removidos', tag: 'FilesProvider');
  }

  Future<Object> shared({Offset? position}) async {
    try {
      final validFiles = xfiles;
      if (validFiles.isEmpty) {
        return ShareResult(
          'Sem arquivos para compartilhar',
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
      return SharePlus.instance.share(params);
    } catch (e) {
      AppLogger.error(
        'Erro ao compartilhar arquivos: $e',
        tag: 'FilesProvider',
      );
      return ShareResult(
        'Erro ao compartilhar arquivos',
        ShareResultStatus.unavailable,
      );
    }
  }
}
