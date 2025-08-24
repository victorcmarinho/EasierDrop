import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:easier_drop/services/logger.dart';

/// Representa um arquivo no shelf. Imutável.
class FileReference {
  final Uint8List? iconData;
  final String pathname;
  const FileReference({this.iconData, required this.pathname});

  String get fileName => pathname.split(Platform.pathSeparator).last;
  String get extension => pathname.split('.').last.toLowerCase();
  Future<int> get size async => File(pathname).length();

  Future<bool> isValidAsync() async {
    try {
      final file = File(pathname);
      final exists = await file.exists();
      if (!exists) return false;
      final stat = await file.stat();
      if (stat.type != FileSystemEntityType.file) return false;

      // Teste rápido de permissão de leitura: tenta abrir e ler 1 byte (ou 0 se vazio)
      RandomAccessFile? raf;
      try {
        raf = await file.open(mode: FileMode.read);
        // readByte retorna -1 em EOF (arquivo vazio) — ainda considera válido
        await raf.readByte();
        return true;
      } on FileSystemException catch (e) {
        AppLogger.warn(
          'Sem permissão de leitura: $pathname (${e.osError?.message})',
          tag: 'FileRef',
        );
        return false;
      } catch (e) {
        AppLogger.warn(
          'Falha ao testar leitura: $pathname ($e)',
          tag: 'FileRef',
        );
        return false;
      } finally {
        try {
          await raf?.close();
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Erro ao validar arquivo: $e');
      return false;
    }
  }

  bool isValidSync() {
    try {
      final file = File(pathname);
      if (!file.existsSync()) return false;
      if (file.statSync().type != FileSystemEntityType.file) return false;
      // Testa abrir para leitura
      RandomAccessFile? raf;
      try {
        raf = file.openSync(mode: FileMode.read);
      } on FileSystemException catch (e) {
        AppLogger.warn(
          'Sem permissão leitura (sync): $pathname (${e.osError?.message})',
          tag: 'FileRef',
        );
        return false;
      } finally {
        try {
          raf?.closeSync();
        } catch (_) {}
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  FileReference withIcon(Uint8List? icon) =>
      FileReference(pathname: pathname, iconData: icon);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileReference && other.pathname == pathname);
  @override
  int get hashCode => pathname.hashCode;
  @override
  String toString() => 'FileReference(pathname: $pathname)';
}
