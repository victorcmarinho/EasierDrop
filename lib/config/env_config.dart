import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static String get aptabaseAppKey =>
      dotenv.get('APTABASE_APP_KEY', fallback: '');

  static String get githubLatestReleaseUrl => dotenv.get(
    'GITHUB_LATEST_RELEASE_URL',
    fallback:
        'https://api.github.com/repos/victorcmarinho/EasierDrop/releases/latest',
  );

  static bool get isValid => aptabaseAppKey.isNotEmpty;
}
