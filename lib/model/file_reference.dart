import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:easier_drop/services/logger.dart';

/// Representa uma referência imutável a um arquivo no sistema
///
/// Contém informações sobre o arquivo incluindo:
/// - Caminho completo do arquivo
/// - Dados do ícone (opcional)
/// - Métodos para validação e propriedades derivadas
@immutable
class FileReference {
  final String pathname;
  final Uint8List? iconData;

  const FileReference({required this.pathname, this.iconData});

  /// Nome do arquivo (sem o caminho)
  String get fileName => pathname.split(Platform.pathSeparator).last;

  /// Extensão do arquivo em minúsculas
  String get extension {
    final base = fileName;
    final dotIndex = base.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == base.length - 1) {
      return base.toLowerCase();
    }
    return base.substring(dotIndex + 1).toLowerCase();
  }

  /// Tamanho do arquivo em bytes
  Future<int> get size async => File(pathname).length();

  /// Verifica se o arquivo é válido de forma assíncrona
  ///
  /// Um arquivo é considerado válido se:
  /// - Existe no sistema de arquivos
  /// - É realmente um arquivo (não um diretório)
  /// - Pode ser lido (tem permissões adequadas)
  Future<bool> isValidAsync() async {
    try {
      final file = File(pathname);

      // Verifica existência
      if (!await file.exists()) return false;

      // Verifica se é um arquivo
      final stat = await file.stat();
      if (stat.type != FileSystemEntityType.file) return false;

      // Testa permissões de leitura
      return await _testFileReadability(file);
    } catch (e) {
      AppLogger.debug(
        'Erro ao validar arquivo: $pathname ($e)',
        tag: 'FileRef',
      );
      return false;
    }
  }

  /// Testa se o arquivo pode ser lido
  Future<bool> _testFileReadability(File file) async {
    RandomAccessFile? raf;
    try {
      raf = await file.open(mode: FileMode.read);
      await raf.readByte();
      return true;
    } on FileSystemException catch (e) {
      AppLogger.warn(
        'Sem permissão de leitura: $pathname (${e.osError?.message})',
        tag: 'FileRef',
      );
      return false;
    } catch (e) {
      AppLogger.warn('Falha ao testar leitura: $pathname ($e)', tag: 'FileRef');
      return false;
    } finally {
      try {
        await raf?.close();
      } catch (_) {
        // Ignora erros ao fechar
      }
    }
  }

  /// Verifica se o arquivo é válido de forma síncrona
  ///
  /// Versão mais rápida mas menos robusta da validação.
  /// Usado principalmente para verificações em lote.
  bool isValidSync() {
    try {
      final file = File(pathname);

      // Verifica existência
      if (!file.existsSync()) return false;

      // Verifica se é um arquivo
      if (file.statSync().type != FileSystemEntityType.file) return false;

      // Testa permissões básicas
      return _testFileReadabilitySync(file);
    } catch (_) {
      return false;
    }
  }

  /// Testa permissões de leitura de forma síncrona
  bool _testFileReadabilitySync(File file) {
    RandomAccessFile? raf;
    try {
      raf = file.openSync(mode: FileMode.read);
      return true;
    } on FileSystemException catch (e) {
      AppLogger.warn(
        'Sem permissão leitura (sync): $pathname (${e.osError?.message})',
        tag: 'FileRef',
      );
      return false;
    } finally {
      try {
        raf?.closeSync();
      } catch (_) {
        // Ignora erros ao fechar
      }
    }
  }

  /// Cria uma nova instância com ícone atualizado
  FileReference withIcon(Uint8List? icon) =>
      FileReference(pathname: pathname, iconData: icon);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileReference && other.pathname == pathname);

  @override
  int get hashCode => pathname.hashCode;

  @override
  String toString() =>
      'FileReference(pathname: $pathname, hasIcon: ${iconData != null})';
}
