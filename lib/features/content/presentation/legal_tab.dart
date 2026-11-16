import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../changes/application/change_providers.dart';
import '../../settings/application/settings_controller.dart';
import '../../settings/domain/app_settings.dart';
import '../application/content_providers.dart';
import '../data/content_repository.dart';
import '../domain/legal.dart';
import 'content_workspace.dart';

String dataLabel(AppLocalizations l10n, DataCategory d) => switch (d) {
  DataCategory.contact => l10n.dataContact,
  DataCategory.location => l10n.dataLocation,
  DataCategory.photos => l10n.dataPhotos,
  DataCategory.audio => l10n.dataAudio,
  DataCategory.contacts => l10n.dataContacts,
  DataCategory.usage => l10n.dataUsage,
  DataCategory.crashDiagnostics => l10n.dataCrash,
  DataCategory.advertisingId => l10n.dataAdId,
  DataCategory.payment => l10n.dataPayment,
};

/// Questionnaire puis modèles modifiables : politique de confidentialité,
/// mentions légales, bannière de consentement.
class LegalTab extends ConsumerStatefulWidget {
  const LegalTab(this.ctx, {super.key});

  final ContentContext ctx;

  @override
  ConsumerState<LegalTab> createState() => _LegalTabState();
}

enum _Field {
  appName,
  publisherName,
  address,
  email,
  companyId,
  hostName,
  hostAddress,
}

class _LegalTabState extends ConsumerState<LegalTab> {
  late LegalAnswers _answers;
  late final _controllers = {
    for (final f in _Field.values) f: TextEditingController(),
  };
  final _thirdParty = TextEditingController();
  late AppLanguage _docLang = ref.read(settingsControllerProvider).language;
  bool _prefilled = false;
  final _docs = <String, TextEditingController>{};

  int? get _sessionId => widget.ctx.ws.activeSession?.id;

  @override
  void initState() {
    super.initState();
    final r = widget.ctx.report;
    _answers = r == null
        ? LegalAnswers(appName: widget.ctx.ws.project.name)
        : LegalAnswers.fromDetection(r, appName: widget.ctx.ws.project.name);
    _prefilled = r != null;
    _syncControllers();
    _load();
  }

  @override
  void dispose() {
    for (final c in [..._controllers.values, _thirdParty, ..._docs.values]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final id = _sessionId;
    if (id == null) return;
    final saved = await ref
        .read(contentRepositoryProvider)
        .latestJson(id, ContentRepository.legalAnswersKey);
    if (saved is! Map || !mounted) return;
    setState(() {
      _answers = LegalAnswers.fromJson(saved.cast());
      _prefilled = false;
      _syncControllers();
    });
  }

  void _syncControllers() {
    final a = _answers;
    _controllers[_Field.appName]!.text = a.appName;
    _controllers[_Field.publisherName]!.text = a.publisherName;
    _controllers[_Field.address]!.text = a.address;
    _controllers[_Field.email]!.text = a.email;
    _controllers[_Field.companyId]!.text = a.companyId;
    _controllers[_Field.hostName]!.text = a.hostName;
    _controllers[_Field.hostAddress]!.text = a.hostAddress;
  }

  /// Réponses avec le contenu actuel des champs texte.
  LegalAnswers get _current => _answers.copyWith(
    appName: _controllers[_Field.appName]!.text,
    publisherName: _controllers[_Field.publisherName]!.text,
    address: _controllers[_Field.address]!.text,
    email: _controllers[_Field.email]!.text,
    companyId: _controllers[_Field.companyId]!.text,
    hostName: _controllers[_Field.hostName]!.text,
    hostAddress: _controllers[_Field.hostAddress]!.text,
  );

  Map<String, String> _paths(LegalAnswers a) {
    final fr = _docLang == AppLanguage.fr;
    return {
      fr ? 'legal/politique-de-confidentialite.md' : 'legal/privacy-policy.md':
          privacyPolicy(a, _docLang, DateTime.now()),
      fr ? 'legal/mentions-legales.md' : 'legal/legal-notice.md': legalNotice(
        a,
        _docLang,
      ),
      if (a.usesCookies) 'legal/cookie-banner.html': cookieBanner(a, _docLang),
    };
  }

  void _generate() => setState(() {
    for (final c in _docs.values) {
      c.dispose();
    }
    _docs
      ..clear()
      ..addAll({
        for (final e in _paths(_current).entries)
          e.key: TextEditingController(text: e.value),
      });
  });

  Future<void> _save() async {
    final l10n = context.l10n;
    _answers = _current;
    await ref
        .read(contentRepositoryProvider)
        .saveJson(
          _sessionId!,
          ContentRepository.legalAnswersKey,
          _answers.toJson(),
        );
    if (mounted) showInfo(ScaffoldMessenger.of(context), l10n.legalSaved);
  }

  Future<void> _write() async {
    final l10n = context.l10n;
    final set = await ref.read(projectWriterProvider).plan(
      widget.ctx.root,
      l10n.legalLabel,
      {for (final e in _docs.entries) e.key: e.value.text},
    );
    if (!mounted) return;
    await previewAndWrite(context, ref, set);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final a = _current;
    final missingNames = {
      'appName': l10n.legalAppName,
      'publisherName': l10n.legalPublisherName,
      'email': l10n.legalEmail,
      'hostName': l10n.legalHostName,
    };

    Widget field(_Field f, String label) => TextField(
      key: ValueKey('legal-${f.name}'),
      controller: _controllers[f],
      decoration: InputDecoration(labelText: label, isDense: true),
      onChanged: (_) => setState(() {}),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Container(
          key: const ValueKey('legal-disclaimer'),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: palette.statusWarning.withValues(alpha: 0.12),
            border: Border.all(
              color: palette.statusWarning.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.gavel, color: palette.statusWarning),
              const SizedBox(width: 10),
              Expanded(child: Text(l10n.legalDisclaimer)),
            ],
          ),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              if (_sessionId == null)
                Text(
                  l10n.contentNeedsSession,
                  style: TextStyle(color: palette.statusWarning),
                ),
              if (_prefilled)
                Text(
                  l10n.legalPrefilled,
                  style: TextStyle(color: palette.statusPedagogy),
                ),
              field(_Field.appName, l10n.legalAppName),
              Text(l10n.legalPublisherType, style: theme.textTheme.labelLarge),
              SegmentedButton<PublisherType>(
                segments: [
                  ButtonSegment(
                    value: PublisherType.individual,
                    label: Text(l10n.publisherIndividual),
                  ),
                  ButtonSegment(
                    value: PublisherType.company,
                    label: Text(l10n.publisherCompany),
                  ),
                ],
                selected: {a.publisherType},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(
                  () => _answers = _answers.copyWith(publisherType: s.first),
                ),
              ),
              field(_Field.publisherName, l10n.legalPublisherName),
              if (a.publisherType == PublisherType.company)
                field(_Field.companyId, l10n.legalCompanyId),
              field(_Field.address, l10n.legalAddress),
              field(_Field.email, l10n.legalEmail),
              field(_Field.hostName, l10n.legalHostName),
              field(_Field.hostAddress, l10n.legalHostAddress),
              Text(l10n.legalData, style: theme.textTheme.labelLarge),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final d in DataCategory.values)
                    FilterChip(
                      key: ValueKey('legal-data-${d.name}'),
                      label: Text(dataLabel(l10n, d)),
                      selected: a.data.contains(d),
                      onSelected: (v) => setState(() {
                        _answers = _answers.copyWith(
                          data: v
                              ? {..._answers.data, d}
                              : ({..._answers.data}..remove(d)),
                        );
                      }),
                    ),
                ],
              ),
              Text(l10n.legalThirdParties, style: theme.textTheme.labelLarge),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final t in a.thirdParties)
                    InputChip(
                      label: Text(t),
                      onDeleted: () => setState(() {
                        _answers = _answers.copyWith(
                          thirdParties: [..._answers.thirdParties]..remove(t),
                        );
                      }),
                    ),
                ],
              ),
              TextField(
                key: const ValueKey('legal-add-third-party'),
                controller: _thirdParty,
                decoration: InputDecoration(
                  labelText: l10n.legalAddThirdParty,
                  isDense: true,
                ),
                onSubmitted: (v) => setState(() {
                  if (v.trim().isEmpty) return;
                  _answers = _answers.copyWith(
                    thirdParties: [..._answers.thirdParties, v.trim()],
                  );
                  _thirdParty.clear();
                }),
              ),
              Text(l10n.legalRetention(a.retentionMonths)),
              Slider(
                value: a.retentionMonths.toDouble(),
                min: 1,
                max: 60,
                divisions: 59,
                label: '${a.retentionMonths}',
                onChanged: (v) => setState(
                  () =>
                      _answers = _answers.copyWith(retentionMonths: v.round()),
                ),
              ),
              SwitchListTile(
                key: const ValueKey('legal-cookies'),
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.legalCookies),
                value: a.usesCookies,
                onChanged: (v) => setState(
                  () => _answers = _answers.copyWith(usesCookies: v),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.legalMinors),
                value: a.allowsMinors,
                onChanged: (v) => setState(
                  () => _answers = _answers.copyWith(allowsMinors: v),
                ),
              ),
              if (a.missing.isNotEmpty)
                Text(
                  l10n.legalMissing(
                    a.missing.map((m) => missingNames[m] ?? m).join(', '),
                  ),
                  style: TextStyle(color: palette.statusWarning),
                ),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    key: const ValueKey('legal-save'),
                    onPressed: _sessionId == null ? null : _save,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(l10n.legalSave),
                  ),
                  Text(l10n.legalDocLanguage),
                  SegmentedButton<AppLanguage>(
                    segments: [
                      ButtonSegment(
                        value: AppLanguage.fr,
                        label: Text(l10n.languageFrench),
                      ),
                      ButtonSegment(
                        value: AppLanguage.en,
                        label: Text(l10n.languageEnglish),
                      ),
                    ],
                    selected: {_docLang},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) =>
                        setState(() => _docLang = s.first),
                  ),
                  FilledButton.tonalIcon(
                    key: const ValueKey('legal-generate'),
                    onPressed: _generate,
                    icon: const Icon(Icons.description_outlined),
                    label: Text(l10n.legalGenerate),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_docs.isNotEmpty)
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                for (final e in _docs.entries) ...[
                  Text(
                    e.key,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                  TextField(
                    key: ValueKey('legal-doc-${e.key}'),
                    controller: e.value,
                    minLines: 6,
                    maxLines: 14,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ],
                FilledButton.icon(
                  key: const ValueKey('legal-write'),
                  onPressed: _write,
                  icon: const Icon(Icons.difference_outlined),
                  label: Text(l10n.contentPreviewWrite),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
