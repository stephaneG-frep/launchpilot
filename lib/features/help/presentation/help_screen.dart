import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/page_frame.dart';
import '../../publication/presentation/level_cards.dart';
import '../../settings/application/settings_controller.dart';
import '../domain/glossary.dart';
import '../domain/manual.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  String _query = '';
  String _manualQuery = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final language = ref.watch(
      settingsControllerProvider.select((s) => s.language),
    );
    final entries = Glossary.search(Glossary.forLanguage(language), _query);
    final manual = [
      for (final section in Manual.forLanguage(language))
        if (section.matches(_manualQuery)) section,
    ];

    final guide = [
      l10n.helpGuideStep1,
      l10n.helpGuideStep2,
      l10n.helpGuideStep3,
      l10n.helpGuideStep4,
      l10n.helpGuideStep5,
    ];

    return PageFrame(
      icon: Icons.help,
      title: l10n.helpTitle,
      subtitle: l10n.helpSubtitle,
      showsDemoData: false,
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(l10n.helpGuideTitle, style: theme.textTheme.titleLarge),
              for (var i = 0; i < guide.length; i++)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.18,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(guide[i])),
                  ],
                ),
              Text(
                l10n.helpGuideNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(l10n.helpManualTitle, style: theme.textTheme.titleLarge),
              TextField(
                key: const ValueKey('manual-search'),
                decoration: InputDecoration(
                  labelText: l10n.helpManualSearch,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _manualQuery = v),
              ),
              if (manual.isEmpty) Text(l10n.helpGlossaryNoResult),
              for (final section in manual)
                ExpansionTile(
                  // La clé change avec la recherche : les chapitres trouvés
                  // s'ouvrent, et se referment quand la recherche est vidée.
                  key: ValueKey(
                    'manual-${section.id}${_manualQuery.trim().isEmpty ? '' : '-found'}',
                  ),
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 12),
                  initiallyExpanded: _manualQuery.trim().isNotEmpty,
                  title: Text(section.title, style: theme.textTheme.titleSmall),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final p in section.paragraphs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(p),
                      ),
                  ],
                ),
            ],
          ),
        ),
        const LevelOverview(),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(l10n.helpShortcutsTitle, style: theme.textTheme.titleLarge),
              _Shortcut(
                keys: 'Ctrl+1 … Ctrl+9, Ctrl+0',
                description: l10n.helpShortcutNav,
              ),
              _Shortcut(
                keys: l10n.helpKeysTab,
                description: l10n.helpShortcutTab,
              ),
              _Shortcut(
                keys: l10n.helpKeysActivate,
                description: l10n.helpShortcutActivate,
              ),
            ],
          ),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(l10n.helpGlossaryTitle, style: theme.textTheme.titleLarge),
              TextField(
                key: const ValueKey('glossary-search'),
                decoration: InputDecoration(
                  labelText: l10n.helpGlossarySearch,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              if (entries.isEmpty) Text(l10n.helpGlossaryNoResult),
              for (final e in entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        e.term,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      Text(e.definition),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.keys, required this.description});

  final String keys;
  final String description;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: scheme.outline),
            color: scheme.surfaceContainerHigh,
          ),
          child: Text(
            keys,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
        ),
        Text(description),
      ],
    );
  }
}
