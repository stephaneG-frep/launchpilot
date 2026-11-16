import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';

/// Bouton volontairement désactivé pour une fonction non implémentée.
/// Il annonce la phase prévue au lieu de prétendre fonctionner.
class LaterPhaseButton extends StatelessWidget {
  const LaterPhaseButton({
    super.key,
    required this.label,
    required this.icon,
    required this.phase,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final int phase;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 8),
        Text(
          l10n.phaseBadge(phase),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
    return Tooltip(
      message: l10n.laterPhaseTooltip(phase),
      child: filled
          ? FilledButton.icon(onPressed: null, icon: Icon(icon), label: child)
          : OutlinedButton.icon(
              onPressed: null,
              icon: Icon(icon),
              label: child,
            ),
    );
  }
}
