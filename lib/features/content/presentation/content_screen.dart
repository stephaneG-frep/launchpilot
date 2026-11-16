import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/adaptive_grid.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/page_frame.dart';
import '../../demo/demo_catalog.dart';
import '../../demo/demo_providers.dart';
import 'content_workspace.dart';

class ContentScreen extends ConsumerWidget {
  const ContentScreen({super.key, this.tab});

  /// Outil à ouvrir, d'après l'adresse (`/content?tab=icons`).
  final String? tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final demo = ref.watch(demoCatalogProvider);

    return PageFrame(
      icon: Icons.photo_library,
      title: l10n.contentTitle,
      subtitle: l10n.contentSubtitle,
      children: [
        if (demo == null)
          ContentWorkspace(
            initialTool: ContentTool.values
                .where((t) => t.name == tab)
                .firstOrNull,
          )
        else
          AdaptiveGrid(
            minItemWidth: 340,
            maxColumns: 2,
            children: [
              _Section(
                icon: Icons.text_fields,
                title: l10n.contentTexts,
                action: const DemoTag(),
                child: _ListingFields(demo.listing),
              ),
              _Section(
                icon: Icons.storefront_outlined,
                title: l10n.contentPreview,
                action: const DemoTag(),
                child: _StorePreview(demo.listing),
              ),
            ],
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
    required this.action,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.secondary),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
            ],
          ),
          DefaultTextStyle.merge(
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            child: child,
          ),
          Align(alignment: Alignment.centerLeft, child: action),
        ],
      ),
    );
  }
}

/// Champs en lecture seule du projet de démonstration.
class _ListingFields extends StatelessWidget {
  const _ListingFields(this.listing);

  final DemoStoreListing listing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget field(String label, String value) => TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(labelText: label),
    );
    return Column(
      spacing: 12,
      children: [
        field(l10n.fieldTitle, listing.title),
        field(l10n.fieldSubtitle, listing.subtitle),
        field(l10n.fieldShortDescription, listing.shortDescription),
        field(l10n.fieldKeywords, listing.keywords.join(', ')),
      ],
    );
  }
}

class _StorePreview extends StatelessWidget {
  const _StorePreview(this.listing);

  final DemoStoreListing listing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = LaunchPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [BrandColors.turquoise, BrandColors.indigo],
                  ),
                ),
                child: const Icon(
                  Icons.wb_sunny_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(listing.title, style: theme.textTheme.titleLarge),
                    Text(
                      listing.subtitle,
                      style: TextStyle(color: scheme.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            listing.shortDescription,
            style: TextStyle(color: scheme.onSurface),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final k in listing.keywords)
                Pill(label: k, color: scheme.primary),
            ],
          ),
        ],
      ),
    );
  }
}
