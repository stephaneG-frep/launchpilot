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
import 'detection_workspace.dart';

class DetectionScreen extends ConsumerWidget {
  const DetectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final demo = ref.watch(demoCatalogProvider);

    return PageFrame(
      icon: Icons.radar,
      title: l10n.detectionTitle,
      subtitle: l10n.detectionSubtitle,
      children: demo == null
          ? const [DetectionWorkspace()]
          : [
              SectionTitle(l10n.detectionTechnologies),
              AdaptiveGrid(
                minItemWidth: 320,
                maxColumns: 2,
                children: [for (final d in demo.detections) _DetectionCard(d)],
              ),
              SectionTitle(l10n.detectionTargets),
              AdaptiveGrid(
                minItemWidth: 220,
                children: [for (final t in demo.targets) _TargetCard(t)],
              ),
            ],
    );
  }
}

class _DetectionCard extends StatelessWidget {
  const _DetectionCard(this.detection);

  final DemoDetection detection;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final percent = (detection.confidence * 100).round();
    final color = detection.confidence >= 0.9
        ? palette.statusSucceeded
        : palette.statusWarning;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  detection.technology,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const DemoTag(),
            ],
          ),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: detection.confidence,
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text(
                l10n.detectionConfidence(percent),
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
          Text(l10n.detectionEvidence, style: theme.textTheme.labelLarge),
          for (final e in detection.evidence)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.subdirectory_arrow_right,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: SelectableText(
                    e,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard(this.target);

  final DemoTarget target;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final color = target.detected
        ? palette.statusSucceeded
        : palette.statusTodo;

    return GlassCard(
      accent: target.detected ? color : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(target.label, style: theme.textTheme.titleMedium),
          Pill(
            label: target.detected
                ? l10n.detectionTargetDetected
                : l10n.detectionTargetNotDetected,
            color: color,
            icon: target.detected ? Icons.check : Icons.remove,
          ),
          Text(
            target.note,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
