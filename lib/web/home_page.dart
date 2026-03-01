import 'package:flutter/material.dart';
import 'package:easier_drop/l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
import 'package:easier_drop/web/website_app.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _changelogContent = '';

  @override
  void initState() {
    super.initState();
    _loadChangelog();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadChangelog();
  }

  Future<void> _loadChangelog() async {
    final loc = AppLocalizations.of(context);
    String fileName = 'CHANGELOG.md'; // Default English
    if (loc?.localeName == 'pt') {
      fileName = 'CHANGELOG_pt.md';
    } else if (loc?.localeName == 'es') {
      fileName = 'CHANGELOG_es.md';
    }

    try {
      final content = await rootBundle.loadString(fileName);
      if (mounted) {
        setState(() {
          _changelogContent = content;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _changelogContent = 'Failed to load changelog: $e';
        });
      }
    }
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(loc, theme),
            _buildHero(loc, theme),
            _buildFeatures(loc, theme),
            _buildChangelog(loc, theme),
            _buildFooter(loc, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations loc, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      color: theme.colorScheme.surface.withValues(alpha: 0.8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset('assets/icon/icon.png', width: 40, height: 40),
              const SizedBox(width: 12),
              Text(
                'Easier Drop',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Row(
            children: [
              DropdownButton<String>(
                value: loc.localeName,
                underline: const SizedBox.shrink(),
                icon: Icon(
                  Icons.language,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'en',
                    child: Text(
                      'English',
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'es',
                    child: Text(
                      'Español',
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'pt',
                    child: Text(
                      'Português',
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  ),
                ],
                dropdownColor: theme.colorScheme.surfaceContainer,
                onChanged: (val) {
                  if (val != null) {
                    WebsiteApp.setLocale(context, Locale(val));
                  }
                },
              ),
              const SizedBox(width: 24),
              ElevatedButton(
                onPressed: () => _launchUrl(
                  'https://github.com/victorcmarinho/EasierDrop/releases',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(loc.webDownloadMac),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHero(AppLocalizations loc, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          Text(
            loc.webHeroTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            loc.webHeroSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _launchUrl(
                  'https://github.com/victorcmarinho/EasierDrop/releases',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 18,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(loc.webDownloadMac),
              ),
              const SizedBox(width: 20),
              OutlinedButton(
                onPressed: () =>
                    _launchUrl('https://github.com/victorcmarinho/EasierDrop'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 18,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  foregroundColor: theme.colorScheme.onSurface,
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('GitHub'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              '> brew tap victorcmarinho/easier-drop https://github.com/victorcmarinho/EasierDrop\n> brew install --cask easier-drop',
              style: TextStyle(
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 60),
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset('assets/promo/demo.webp', fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures(AppLocalizations loc, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Text(
            loc.webFeaturesTitle,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              SizedBox(
                width: 300,
                child: _buildFeatureCard(
                  Icons.archive,
                  loc.webFeature1Title,
                  loc.webFeature1Desc,
                  theme,
                ),
              ),
              SizedBox(
                width: 300,
                child: _buildFeatureCard(
                  Icons.layers,
                  loc.webFeature2Title,
                  loc.webFeature2Desc,
                  theme,
                ),
              ),
              SizedBox(
                width: 300,
                child: _buildFeatureCard(
                  Icons.vibration,
                  loc.webFeature3Title,
                  loc.webFeature3Desc,
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String desc,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangelog(AppLocalizations loc, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 800),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.webChangelogTitle,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _changelogContent.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : MarkdownBody(
                    data: _changelogContent,
                    styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                      p: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      h1: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      h2: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      h3: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(AppLocalizations loc, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        loc.webFooterText,
        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}
