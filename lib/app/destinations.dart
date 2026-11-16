import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

enum NavGroup { project, tools, app }

/// Les dix écrans de LaunchPilot, dans l'ordre de la navigation.
/// L'ordre détermine aussi les raccourcis Ctrl+1 … Ctrl+9, Ctrl+0.
enum AppDestination {
  home('/', Icons.home_outlined, Icons.home, NavGroup.project),
  detection('/detection', Icons.radar_outlined, Icons.radar, NavGroup.project),
  publication(
    '/publication',
    Icons.rocket_launch_outlined,
    Icons.rocket_launch,
    NavGroup.project,
  ),
  checklist(
    '/checklist',
    Icons.checklist_outlined,
    Icons.checklist,
    NavGroup.project,
  ),
  terminal(
    '/terminal',
    Icons.terminal_outlined,
    Icons.terminal,
    NavGroup.tools,
  ),
  agent('/agent', Icons.forum_outlined, Icons.forum, NavGroup.tools),
  content(
    '/content',
    Icons.photo_library_outlined,
    Icons.photo_library,
    NavGroup.tools,
  ),
  reports(
    '/reports',
    Icons.description_outlined,
    Icons.description,
    NavGroup.tools,
  ),
  settings('/settings', Icons.settings_outlined, Icons.settings, NavGroup.app),
  help('/help', Icons.help_outline, Icons.help, NavGroup.app);

  const AppDestination(this.path, this.icon, this.selectedIcon, this.group);

  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final NavGroup group;

  /// Touche du raccourci clavier : 1 à 9 puis 0 pour le dixième écran.
  String get shortcutKey => '${(index + 1) % 10}';

  String label(AppLocalizations l10n) => switch (this) {
    home => l10n.navHome,
    detection => l10n.navDetection,
    publication => l10n.navPublication,
    checklist => l10n.navChecklist,
    terminal => l10n.navTerminal,
    agent => l10n.navAgent,
    content => l10n.navContent,
    reports => l10n.navReports,
    settings => l10n.navSettings,
    help => l10n.navHelp,
  };

  static AppDestination fromLocation(String location) {
    for (final d in values.reversed) {
      if (d != home && location.startsWith(d.path)) return d;
    }
    return home;
  }
}

extension NavGroupL10n on NavGroup {
  String label(AppLocalizations l10n) => switch (this) {
    NavGroup.project => l10n.navGroupProject,
    NavGroup.tools => l10n.navGroupTools,
    NavGroup.app => l10n.navGroupApp,
  };
}
