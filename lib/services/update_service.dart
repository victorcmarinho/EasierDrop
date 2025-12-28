import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:easier_drop/services/logger.dart';

class UpdateService {
  static final UpdateService instance = UpdateService._();
  UpdateService._();

  Future<String?> checkForUpdates() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.github.com/repos/victorcmarinho/EasierDrop/releases/latest',
        ),
      );

      if (response.statusCode == 200) {
        AppLogger.info('Update check successful');
        final data = json.decode(response.body);
        AppLogger.info('Update data: $data');
        final tagName = data['tag_name'] as String;
        AppLogger.info('Update tag name: $tagName');
        final releaseUrl = data['html_url'] as String;
        AppLogger.info('Update release URL: $releaseUrl');

        final cleanVersion =
            tagName.startsWith('v') ? tagName.substring(1) : tagName;
        final latestVersion = Version.parse(cleanVersion);

        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = Version.parse(packageInfo.version);

        if (latestVersion > currentVersion) {
          return releaseUrl;
        }
      }
    } catch (e) {
      AppLogger.warn('Failed to check for updates: $e');
    }
    return null;
  }
}
