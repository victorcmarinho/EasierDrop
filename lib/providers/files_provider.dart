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

  List<FileReference>? _lastCleared; // snapshot para undo

  List<FileReference> get files => _files.values.toList(growable: false);

  List<XFile> get xfiles => _files.values
      .where((f) => f.isValidSync())
      .map((f) => XFile(f.pathname))
      .toList(growable: false);

  bool get isEmpty => _files.isEmpty;

  bool _notifyScheduled = false;
  void _scheduleNotify() {
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    scheduleMicrotask(() {
      _notifyScheduled = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    // nenhum recurso pendente além do microtask agendado
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
      AppLogger.info(
        'Arquivo adicionado: ${file.fileName}',
        tag: 'FilesProvider',
      );
    } catch (e) {
      AppLogger.error('Erro ao adicionar arquivo: $e', tag: 'FilesProvider');
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
    if (_files.isEmpty) return;
    _lastCleared = _files.values.toList(growable: false);
    final count = _files.length;
    _files.clear();
    _scheduleNotify();
    AppLogger.info('$count arquivos removidos', tag: 'FilesProvider');
  }

  bool get canUndo => _lastCleared != null && _lastCleared!.isNotEmpty;

  void undoClear() {
    if (!canUndo) return;
    for (final f in _lastCleared!) {
      _files[f.pathname] = f;
    }
    _lastCleared = null;
    _scheduleNotify();
    AppLogger.info('Restauração concluída', tag: 'FilesProvider');
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
