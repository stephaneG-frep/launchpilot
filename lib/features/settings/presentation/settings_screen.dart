import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/hosting.dart';
import '../../../core/domain/explanation_level.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/page_frame.dart';
import '../../llm/domain/llm_provider_id.dart';
import '../application/settings_controller.dart';
import '../domain/app_settings.dart';
import '../../llm/presentation/llm_trial_card.dart';
import 'api_key_tile.dart';
import 'local_data_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return PageFrame(
      icon: Icons.settings,
      title: l10n.settingsTitle,
      subtitle: l10n.settingsSubtitle,
      showsDemoData: false,
      children: [
        _Section(
          icon: Icons.palette_outlined,
          title: l10n.settingsAppearance,
          children: [
            _Labeled(
              label: l10n.settingsTheme,
              child: SegmentedButton<ThemePreference>(
                key: const ValueKey('settings-theme'),
                segments: [
                  ButtonSegment(
                    value: ThemePreference.system,
                    icon: const Icon(Icons.brightness_auto_outlined),
                    label: Text(l10n.themeSystem),
                  ),
                  ButtonSegment(
                    value: ThemePreference.dark,
                    icon: const Icon(Icons.dark_mode_outlined),
                    label: Text(l10n.themeDark),
                  ),
                  ButtonSegment(
                    value: ThemePreference.light,
                    icon: const Icon(Icons.light_mode_outlined),
                    label: Text(l10n.themeLight),
                  ),
                ],
                selected: {settings.themePreference},
                showSelectedIcon: false,
                onSelectionChanged: (s) =>
                    controller.setThemePreference(s.first),
              ),
            ),
            _Labeled(
              label: l10n.settingsTextSize,
              child: SegmentedButton<TextSizePreference>(
                segments: [
                  ButtonSegment(
                    value: TextSizePreference.normal,
                    label: Text(l10n.textSizeNormal),
                  ),
                  ButtonSegment(
                    value: TextSizePreference.large,
                    label: Text(l10n.textSizeLarge),
                  ),
                  ButtonSegment(
                    value: TextSizePreference.extraLarge,
                    label: Text(l10n.textSizeExtraLarge),
                  ),
                ],
                selected: {settings.textSize},
                showSelectedIcon: false,
                onSelectionChanged: (s) => controller.setTextSize(s.first),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsAnimations),
              subtitle: Text(l10n.settingsAnimationsHint),
              value: settings.animationsEnabled,
              onChanged: controller.setAnimationsEnabled,
            ),
          ],
        ),
        _Section(
          icon: Icons.translate,
          title: l10n.settingsLanguage,
          children: [
            SegmentedButton<AppLanguage>(
              key: const ValueKey('settings-language'),
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
              selected: {settings.language},
              showSelectedIcon: false,
              onSelectionChanged: (s) => controller.setLanguage(s.first),
            ),
          ],
        ),
        _Section(
          icon: Icons.school_outlined,
          title: l10n.settingsGuidance,
          children: [
            for (final level in ExplanationLevel.values)
              _ChoiceCard(
                key: ValueKey('mode-${level.name}'),
                title: level.label(l10n),
                description: level.description(l10n),
                selected: settings.explanationLevel == level,
                onTap: () => controller.setExplanationLevel(level),
              ),
          ],
        ),
        _Section(
          icon: Icons.auto_awesome_outlined,
          title: l10n.settingsAi,
          children: [
            _Labeled(
              label: l10n.settingsAiProvider,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in LlmProviderId.values)
                    ChoiceChip(
                      key: ValueKey('provider-${p.name}'),
                      label: Text(p.label),
                      selected: settings.llmProvider == p,
                      onSelected: (_) => controller.setLlmProvider(p),
                    ),
                ],
              ),
            ),
            _Notice(
              icon: Icons.privacy_tip_outlined,
              text: l10n.settingsAiNetworkPolicy,
            ),
            const Divider(),
            Text(
              l10n.settingsApiKeys,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            _Notice(icon: Icons.key_outlined, text: l10n.settingsApiKeysHint),
            for (final p in LlmProviderId.values)
              ApiKeyTile(key: ValueKey('api-key-${p.name}'), provider: p),
            const Divider(),
            const LlmTrialCard(),
          ],
        ),
        _Section(
          icon: Icons.cloud_upload_outlined,
          title: l10n.settingsHosting,
          children: [
            Text(l10n.settingsHostingHint),
            Text(
              l10n.settingsPreferredHost,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  key: const ValueKey('settings-host-none'),
                  label: Text(l10n.settingsHostNone),
                  selected: settings.preferredHost == null,
                  onSelected: (_) => controller.setPreferredHost(null),
                ),
                for (final h in HostingProvider.values)
                  ChoiceChip(
                    key: ValueKey('settings-host-${h.name}'),
                    label: Text(h.label),
                    selected: settings.preferredHost == h,
                    onSelected: (_) => controller.setPreferredHost(h),
                  ),
              ],
            ),
            Text(
              l10n.settingsAnalytics,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            SegmentedButton<AnalyticsTool>(
              key: const ValueKey('settings-analytics'),
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
              selected: {settings.analytics},
              showSelectedIcon: false,
              onSelectionChanged: (s) => controller.setAnalytics(s.first),
            ),
          ],
        ),
        _Section(
          icon: Icons.terminal,
          title: l10n.settingsExecution,
          children: [
            SwitchListTile(
              key: const ValueKey('settings-simulation'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.terminalSimulationToggle),
              subtitle: Text(l10n.settingsSimulationHint),
              value: settings.simulationMode,
              onChanged: controller.setSimulationMode,
            ),
          ],
        ),
        _Section(
          icon: Icons.storage_outlined,
          title: l10n.settingsLocalData,
          children: const [LocalDataContent()],
        ),
        _Section(
          icon: Icons.science_outlined,
          title: l10n.settingsDemo,
          children: [
            SwitchListTile(
              key: const ValueKey('settings-demo'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsDemo),
              subtitle: Text(l10n.settingsDemoHint),
              value: settings.demoMode,
              onChanged: controller.setDemoMode,
            ),
          ],
        ),
        _Section(
          icon: Icons.privacy_tip_outlined,
          title: l10n.settingsPrivacy,
          children: [Text(l10n.settingsPrivacyText)],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.secondary),
              const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: theme.textTheme.titleLarge),
                ),
              ),
            ],
          ),
          ...children,
        ],
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: child),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: TextStyle(color: scheme.onSurfaceVariant)),
        ),
      ],
    );
  }
}

/// Choix exclusif sous forme de carte, plus explicite qu'un bouton radio.
class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    super.key,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      child: Material(
        color: selected
            ? scheme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(title, style: theme.textTheme.titleSmall),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
