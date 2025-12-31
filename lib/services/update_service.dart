import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:easier_drop/services/logger.dart';
import 'package:easier_drop/helpers/app_constants.dart';

abstract class UpdateClient {
  Future<http.Response> getLatestRelease();
}

class GitHubUpdateClient implements UpdateClient {
  @override
  Future<http.Response> getLatestRelease() {
    return http.get(Uri.parse(AppConstants.githubLatestReleaseUrl));
  }
}

class UpdateService {
  final UpdateClient _client;

  UpdateService({UpdateClient? client})
    : _client = client ?? GitHubUpdateClient();

  static final UpdateService instance = UpdateService();

  Future<String?> checkForUpdates() async {
    try {
      final response = await _client.getLatestRelease();

      if (response.statusCode == 200) {
        AppLogger.info('Update check successful');
        final data = json.decode(response.body);

        final String tagName = data['tag_name'] ?? '';
        final String releaseUrl = data['html_url'] ?? '';

        final packageInfo = await PackageInfo.fromPlatform();

        if (isBetterVersion(tagName, packageInfo.version)) {
          return releaseUrl;
        }
      }
    } catch (e) {
      AppLogger.warn('Failed to check for updates: $e');
    }
    return null;
  }

  bool isBetterVersion(String latestTag, String currentVersion) {
    try {
      if (latestTag.isEmpty) return false;

      final cleanLatest =
          latestTag.startsWith('v') ? latestTag.substring(1) : latestTag;

      final latest = Version.parse(cleanLatest);
      final current = Version.parse(currentVersion);

      return latest > current;
    } catch (e) {
      AppLogger.warn('Version parsing error: $e');
      return false;
    }
  }
}
