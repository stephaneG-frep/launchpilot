import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/core/domain/step_status.dart';
import 'package:launchpilot/core/theme/app_theme.dart';
import 'package:launchpilot/core/theme/launch_palette.dart';

/// Rapport de contraste WCAG 2.x entre deux couleurs opaques.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  for (final brightness in Brightness.values) {
    group('Thème ${brightness.name}', () {
      final theme = AppTheme.build(brightness: brightness);
      final palette = theme.extension<LaunchPalette>()!;
      final scheme = theme.colorScheme;

      test('fournit la palette LaunchPilot', () {
        expect(theme.useMaterial3, isTrue);
        expect(palette, isNotNull);
      });

      test('les couleurs de statut sont lisibles sur le fond (≥ 4,5:1)', () {
        for (final status in StepStatus.values) {
          final color = palette.statusColor(status);
          for (final bg in [palette.backgroundTop, palette.backgroundBottom]) {
            expect(
              contrast(color, bg),
              greaterThanOrEqualTo(4.5),
              reason: '${status.name} sur $bg',
            );
          }
        }
      });

      test('le texte principal est lisible sur la surface (≥ 7:1)', () {
        expect(
          contrast(scheme.onSurface, scheme.surface),
          greaterThanOrEqualTo(7),
        );
        expect(
          contrast(scheme.onSurfaceVariant, scheme.surface),
          greaterThanOrEqualTo(4.5),
        );
      });
    });
  }

  test('le mode Expert densifie l\'interface', () {
    expect(
      AppTheme.build(brightness: Brightness.dark, dense: true).visualDensity,
      VisualDensity.compact,
    );
  });
}
