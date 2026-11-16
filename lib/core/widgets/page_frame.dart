import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/application/settings_controller.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/launch_palette.dart';

/// Gabarit commun des écrans : en-tête, bannière démo éventuelle et contenu
/// centré avec une largeur maximale lisible.
class PageFrame extends ConsumerWidget {
  const PageFrame({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
    this.actions = const [],
    this.showsDemoData = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final List<Widget> actions;

  /// Faux pour les écrans qui n'affichent jamais de données démo.
  final bool showsDemoData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = showsDemoData && ref.watch(demoModeProvider);
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < 600 ? 16.0 : 32.0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(horizontal, 24, horizontal, 40),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              _Header(
                icon: icon,
                title: title,
                subtitle: subtitle,
                actions: actions,
              ),
              if (demo) const DemoBanner(),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final titleBlock = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.primary, scheme.tertiary],
            ),
          ),
          child: Icon(icon, color: scheme.onPrimary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Semantics(
                header: true,
                child: Text(title, style: theme.textTheme.headlineSmall),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    if (actions.isEmpty) return titleBlock;
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: titleBlock,
        ),
        Wrap(spacing: 8, runSpacing: 8, children: actions),
      ],
    );
  }
}

/// Bannière affichée sur chaque écran utilisant les données fictives.
class DemoBanner extends ConsumerWidget {
  const DemoBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final palette = LaunchPalette.of(context);
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      label: l10n.demoBannerTitle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              palette.accentOrange.withValues(alpha: 0.16),
              palette.statusPedagogy.withValues(alpha: 0.12),
            ],
          ),
          border: Border.all(
            color: palette.accentOrange.withValues(alpha: 0.5),
          ),
        ),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.science_outlined, color: palette.accentOrange),
                const SizedBox(width: 12),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${l10n.demoBannerTitle} — ',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: l10n.demoBannerMessage),
                      ],
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => ref
                  .read(settingsControllerProvider.notifier)
                  .setDemoMode(false),
              child: Text(l10n.demoBannerExit),
            ),
          ],
        ),
      ),
    );
  }
}

/// Titre de section à l'intérieur d'un écran.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final title = Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
    // Avec une action, le Wrap la renvoie à la ligne sur fenêtre étroite.
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: trailing == null
          ? title
          : Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [title, trailing!],
            ),
    );
  }
}
