import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/hosting.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/adaptive_grid.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/glass_card.dart';
import '../../changes/application/change_providers.dart';
import '../../content/application/content_providers.dart';
import '../../content/presentation/content_workspace.dart';
import '../../settings/application/settings_controller.dart';
import '../application/web_providers.dart';
import '../domain/seo.dart';
import '../domain/web_audit.dart';
import '../domain/web_build.dart';

/// Clé des réglages SEO dans la session.
const seoSessionKey = 'web.seo';

String _dirOf(String path) {
  final i = path.lastIndexOf('/');
  return i < 0 ? '' : path.substring(0, i);
}

/// Balises SEO, robots.txt, sitemap.xml, données structurées et
/// statistiques respectueuses de la vie privée.
class SeoTab extends ConsumerStatefulWidget {
  const SeoTab(this.ctx, {super.key});

  final ContentContext ctx;

  @override
  ConsumerState<SeoTab> createState() => _SeoTabState();
}

enum _F { title, description, siteUrl, imageUrl, siteName, twitter, locale }

class _SeoTabState extends ConsumerState<SeoTab> {
  final _c = {for (final f in _F.values) f: TextEditingController()};
  final _extraPaths = TextEditingController();
  final _statsScript = TextEditingController();
  final _statsId = TextEditingController();
  SchemaType _schema = SchemaType.website;
  late AnalyticsTool _analytics = ref
      .read(settingsControllerProvider)
      .analytics;

  int? get _sessionId => widget.ctx.ws.activeSession?.id;
  WebBuildPlan? get _plan => ref.read(webBuildPlanProvider);

  @override
  void initState() {
    super.initState();
    _prefill();
    _load();
  }

  @override
  void dispose() {
    for (final c in [..._c.values, _extraPaths, _statsScript, _statsId]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _index() {
    final index = _plan?.sourceIndex;
    return index == null
        ? null
        : ref.read(projectWriterProvider).readCurrent(widget.ctx.root, index);
  }

  void _prefill() {
    final html = _index();
    _c[_F.siteName]!.text = widget.ctx.ws.project.name;
    _c[_F.siteUrl]!.text = ref.read(webConfigProvider).siteUrl;
    _c[_F.locale]!.text =
        ref.read(settingsControllerProvider).language.name == 'fr'
        ? 'fr_FR'
        : 'en_US';
    if (html != null) {
      _c[_F.title]!.text = pageTitle(html) ?? '';
      _c[_F.description]!.text = metaContent(html, 'description') ?? '';
      _c[_F.imageUrl]!.text =
          metaContent(html, 'og:image', by: 'property') ?? '';
    }
  }

  Future<void> _load() async {
    final id = _sessionId;
    if (id == null) return;
    final saved = await ref
        .read(contentRepositoryProvider)
        .latestJson(id, seoSessionKey);
    if (saved is! Map || !mounted) return;
    final m = SeoMeta.fromJson(saved.cast());
    setState(() {
      _c[_F.title]!.text = m.title;
      _c[_F.description]!.text = m.description;
      if (m.siteUrl.isNotEmpty) _c[_F.siteUrl]!.text = m.siteUrl;
      _c[_F.imageUrl]!.text = m.imageUrl;
      _c[_F.siteName]!.text = m.siteName;
      _c[_F.twitter]!.text = m.twitterHandle;
      _c[_F.locale]!.text = m.locale;
      _schema = m.schemaType;
    });
  }

  SeoMeta get _meta => SeoMeta(
    title: _c[_F.title]!.text.trim(),
    description: _c[_F.description]!.text.trim(),
    siteUrl: _c[_F.siteUrl]!.text.trim(),
    imageUrl: _c[_F.imageUrl]!.text.trim(),
    siteName: _c[_F.siteName]!.text.trim(),
    twitterHandle: _c[_F.twitter]!.text.trim(),
    locale: _c[_F.locale]!.text.trim().isEmpty
        ? 'fr_FR'
        : _c[_F.locale]!.text.trim(),
    schemaType: _schema,
  );

  /// Pages connues du site (fichiers HTML des sources), plus les chemins
  /// saisis à la main.
  List<String> _paths(WebBuildPlan plan) {
    final found = <String>[];
    if (!plan.spa) {
      final dir = plan.sourceIndex == null
          ? plan.publicDir
          : _dirOf(plan.sourceIndex!);
      final site = ref.read(siteReaderProvider).read(widget.ctx.root, dir);
      if (site != null) found.addAll(pagePaths(site.htmlFiles));
    }
    final extra = _extraPaths.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .map((l) => l.startsWith('/') ? l : '/$l');
    return {'/', ...found, ...extra}.toList();
  }

  Future<void> _saveMeta() async {
    final meta = _meta;
    await ref
        .read(webConfigProvider.notifier)
        .update(ref.read(webConfigProvider).copyWith(siteUrl: meta.siteUrl));
    final id = _sessionId;
    if (id != null) {
      await ref
          .read(contentRepositoryProvider)
          .saveJson(id, seoSessionKey, meta.toJson());
    }
  }

  Future<void> _write(WebBuildPlan plan) async {
    final l10n = context.l10n;
    final meta = _meta;
    await _saveMeta();
    final files = <String, String>{
      widget.ctx.join(plan.publicDir, 'robots.txt'): robotsTxt(meta.siteUrl),
      widget.ctx.join(plan.publicDir, 'sitemap.xml'): sitemapXml(
        meta.siteUrl,
        _paths(plan),
        DateTime.now(),
      ),
    };
    final html = _index();
    if (html != null) {
      final next = applySeoMeta(html, meta);
      if (next != null) files[plan.sourceIndex!] = next;
    }
    final set = await ref
        .read(projectWriterProvider)
        .plan(widget.ctx.root, l10n.seoLabel, files);
    if (!mounted) return;
    await previewAndWrite(context, ref, set);
  }

  Future<void> _writeAnalytics(WebBuildPlan plan) async {
    final l10n = context.l10n;
    final html = _index();
    if (html == null) return;
    final host = Uri.tryParse(_meta.normalizedUrl)?.host ?? '';
    final next = applyAnalytics(
      html,
      analyticsSnippet(
        _analytics,
        domain: host,
        scriptUrl: _statsScript.text.trim(),
        siteId: _statsId.text.trim(),
      ),
    );
    if (next == null) return;
    final set = await ref.read(projectWriterProvider).plan(
      widget.ctx.root,
      l10n.seoAnalyticsLabel,
      {plan.sourceIndex!: next},
    );
    if (!mounted) return;
    await previewAndWrite(context, ref, set);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final plan = ref.watch(webBuildPlanProvider);
    if (plan == null) return Text(l10n.webNoPlan);
    final meta = _meta;
    final urlOk = meta.siteUrlValid;
    final hasIndex = plan.sourceIndex != null && _index() != null;

    Widget field(
      _F f,
      String label, {
      String? hint,
      int? limit,
      int lines = 1,
    }) {
      final length = _c[f]!.text.trim().length;
      return TextField(
        key: ValueKey('seo-${f.name}'),
        controller: _c[f],
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          isDense: true,
          counterText: limit == null ? null : '$length / $limit',
          counterStyle: TextStyle(
            color: limit != null && length > limit
                ? palette.statusWarning
                : null,
          ),
        ),
        onChanged: (_) => setState(() {}),
      );
    }

    final analyticsReady =
        _analytics != AnalyticsTool.none &&
        urlOk &&
        (_analytics != AnalyticsTool.umami || _statsId.text.trim().isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(l10n.seoHelp),
              field(_F.siteUrl, l10n.seoSiteUrl, hint: 'https://exemple.fr'),
              if (meta.siteUrl.isNotEmpty && !urlOk)
                Text(
                  l10n.seoSiteUrlInvalid,
                  style: TextStyle(color: palette.statusFailed),
                ),
              field(_F.title, l10n.webSeoTitle, limit: 60),
              field(
                _F.description,
                l10n.webSeoDescription,
                limit: 160,
                lines: 3,
              ),
              field(_F.siteName, l10n.seoSiteName),
              field(
                _F.imageUrl,
                l10n.seoImage,
                hint: 'https://exemple.fr/partage.png',
              ),
              Text(l10n.seoImageHint, style: theme.textTheme.bodySmall),
              field(_F.twitter, l10n.seoTwitter, hint: '@compte'),
              field(_F.locale, l10n.seoLocale, hint: 'fr_FR'),
              Text(l10n.seoSchema, style: theme.textTheme.labelLarge),
              SegmentedButton<SchemaType>(
                segments: [
                  ButtonSegment(
                    value: SchemaType.website,
                    label: Text(l10n.seoSchemaWebsite),
                  ),
                  ButtonSegment(
                    value: SchemaType.application,
                    label: Text(l10n.seoSchemaApp),
                  ),
                  ButtonSegment(
                    value: SchemaType.organization,
                    label: Text(l10n.seoSchemaOrg),
                  ),
                ],
                selected: {_schema},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _schema = s.first),
              ),
              if (!plan.spa)
                TextField(
                  key: const ValueKey('seo-extra-paths'),
                  controller: _extraPaths,
                  minLines: 2,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: l10n.seoExtraPaths,
                    hintText: '/contact\n/tarifs',
                    isDense: true,
                  ),
                ),
              if (plan.spa)
                Text(l10n.seoSpaNote, style: theme.textTheme.bodySmall),
              Text(
                l10n.seoFiles(
                  [
                    widget.ctx.join(plan.publicDir, 'robots.txt'),
                    widget.ctx.join(plan.publicDir, 'sitemap.xml'),
                    if (hasIndex) plan.sourceIndex!,
                  ].join(', '),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
              if (!hasIndex) ...[
                Text(
                  l10n.seoManagedHead,
                  style: TextStyle(color: palette.statusPedagogy),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.colorScheme.surfaceContainerLowest,
                  ),
                  child: SelectableText(
                    seoHeadBlock(meta, indent: ''),
                    key: const ValueKey('seo-snippet'),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: seoHeadBlock(meta, indent: '')),
                    );
                    showInfo(ScaffoldMessenger.of(context), l10n.commonCopied);
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: Text(l10n.commonCopy),
                ),
              ],
              FilledButton.icon(
                key: const ValueKey('seo-write'),
                onPressed: urlOk ? () => _write(plan) : null,
                icon: const Icon(Icons.difference_outlined),
                label: Text(l10n.contentPreviewWrite),
              ),
              if (!urlOk)
                Text(l10n.seoNeedsUrl, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        AdaptiveGrid(
          minItemWidth: 300,
          maxColumns: 2,
          children: [
            _SearchPreview(meta: meta),
            _SocialPreview(meta: meta),
          ],
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(l10n.seoAnalyticsTitle, style: theme.textTheme.titleMedium),
              Text(l10n.seoAnalyticsHelp),
              SegmentedButton<AnalyticsTool>(
                key: const ValueKey('seo-analytics-tool'),
                segments: [
                  ButtonSegment(
                    value: AnalyticsTool.none,
                    label: Text(l10n.seoAnalyticsNone),
                  ),
                  const ButtonSegment(
                    value: AnalyticsTool.plausible,
                    label: Text('Plausible'),
                  ),
                  const ButtonSegment(
                    value: AnalyticsTool.umami,
                    label: Text('Umami'),
                  ),
                ],
                selected: {_analytics},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _analytics = s.first),
              ),
              if (_analytics != AnalyticsTool.none) ...[
                TextField(
                  controller: _statsScript,
                  decoration: InputDecoration(
                    labelText: l10n.seoAnalyticsScript,
                    hintText: _analytics == AnalyticsTool.plausible
                        ? 'https://plausible.io/js/script.js'
                        : 'https://cloud.umami.is/script.js',
                    isDense: true,
                  ),
                ),
                if (_analytics == AnalyticsTool.umami)
                  TextField(
                    key: const ValueKey('seo-analytics-id'),
                    controller: _statsId,
                    decoration: InputDecoration(
                      labelText: l10n.seoAnalyticsUmamiId,
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                Text(l10n.seoAnalyticsLegal, style: theme.textTheme.bodySmall),
              ],
              if (hasIndex)
                OutlinedButton.icon(
                  key: const ValueKey('seo-analytics-write'),
                  onPressed: analyticsReady || _analytics == AnalyticsTool.none
                      ? () => _writeAnalytics(plan)
                      : null,
                  icon: const Icon(Icons.difference_outlined),
                  label: Text(
                    _analytics == AnalyticsTool.none
                        ? l10n.seoAnalyticsRemove
                        : l10n.seoAnalyticsAdd,
                  ),
                )
              else if (_analytics != AnalyticsTool.none && urlOk)
                SelectableText(
                  analyticsSnippet(
                    _analytics,
                    domain: Uri.parse(meta.normalizedUrl).host,
                    scriptUrl: _statsScript.text.trim(),
                    siteId: _statsId.text.trim(),
                  ),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchPreview extends StatelessWidget {
  const _SearchPreview({required this.meta});

  final SeoMeta meta;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final title = meta.title.isEmpty ? meta.siteName : meta.title;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(l10n.seoPreviewSearch, style: theme.textTheme.labelLarge),
          Text(
            meta.normalizedUrl.isEmpty ? 'https://…' : meta.normalizedUrl,
            style: theme.textTheme.bodySmall,
          ),
          Text(
            title.length > 60 ? '${title.substring(0, 60)}…' : title,
            style: theme.textTheme.titleMedium?.copyWith(color: scheme.primary),
          ),
          Text(
            meta.description.length > 160
                ? '${meta.description.substring(0, 160)}…'
                : meta.description,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

class _SocialPreview extends StatelessWidget {
  const _SocialPreview({required this.meta});

  final SeoMeta meta;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(l10n.seoPreviewSocial, style: theme.textTheme.labelLarge),
          Container(
            height: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.tertiary],
              ),
            ),
            child: Text(
              meta.imageUrl.isEmpty ? l10n.seoPreviewNoImage : meta.imageUrl,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            Uri.tryParse(meta.normalizedUrl)?.host.toUpperCase() ?? '',
            style: theme.textTheme.bodySmall,
          ),
          Text(
            meta.title.isEmpty ? meta.siteName : meta.title,
            style: theme.textTheme.titleSmall,
          ),
          Text(meta.description, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
