import 'package:flutter/material.dart';

import '../domain/step_status.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/launch_palette.dart';

/// Petite pastille colorée avec libellé.
class Pill extends StatelessWidget {
  const Pill({super.key, required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.status, {super.key});

  final StepStatus status;

  static IconData iconFor(StepStatus status) => switch (status) {
    StepStatus.todo => Icons.radio_button_unchecked,
    StepStatus.running => Icons.autorenew,
    StepStatus.succeeded => Icons.check_circle,
    StepStatus.failed => Icons.error,
    StepStatus.needsValidation => Icons.warning_amber_rounded,
    StepStatus.pedagogical => Icons.school,
  };

  @override
  Widget build(BuildContext context) {
    return Pill(
      label: status.label(context.l10n),
      color: LaunchPalette.of(context).statusColor(status),
      icon: iconFor(status),
    );
  }
}

/// Signale une donnée fictive du mode démo.
class DemoTag extends StatelessWidget {
  const DemoTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Pill(
      label: context.l10n.demoTag,
      color: LaunchPalette.of(context).accentOrange,
      icon: Icons.science_outlined,
    );
  }
}

/// Indique qu'une fonctionnalité arrivera dans une phase ultérieure.
class PhasePill extends StatelessWidget {
  const PhasePill(this.phase, {super.key});

  final int phase;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.l10n.laterPhaseTooltip(phase),
      child: Pill(
        label: context.l10n.phaseBadge(phase),
        color: LaunchPalette.of(context).statusTodo,
        icon: Icons.schedule,
      ),
    );
  }
}
