import 'package:meta/meta.dart';

class Env {
  Env._();
  @visibleForTesting
  static void testCoverage() => Env._();

  static const String aptabaseAppKey = String.fromEnvironment(
    'APTABASE_APP_KEY',
  );

  static const String githubLatestReleaseUrl = String.fromEnvironment(
    'GITHUB_LATEST_RELEASE_URL',
    defaultValue:
        'https://api.github.com/repos/victorcmarinho/EasierDrop/releases/latest',
  );

  static bool get isValid => aptabaseAppKey.isNotEmpty;
}
