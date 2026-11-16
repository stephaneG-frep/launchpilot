import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/agent_chat/presentation/agent_chat_screen.dart';
import '../features/checklist/presentation/checklist_screen.dart';
import '../features/content/presentation/content_screen.dart';
import '../features/detection/presentation/detection_screen.dart';
import '../features/help/presentation/help_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/publication/presentation/publication_board_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/terminal/presentation/terminal_screen.dart';
import 'destinations.dart';
import 'shell/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = createRouter();
  ref.onDispose(router.dispose);
  return router;
});

GoRouter createRouter({String initialLocation = '/'}) {
  Widget screenFor(AppDestination d, GoRouterState state) => switch (d) {
    AppDestination.home => const HomeScreen(),
    AppDestination.detection => const DetectionScreen(),
    AppDestination.publication => const PublicationBoardScreen(),
    AppDestination.checklist => const ChecklistScreen(),
    AppDestination.terminal => const TerminalScreen(),
    AppDestination.agent => const AgentChatScreen(),
    AppDestination.content => ContentScreen(
      tab: state.uri.queryParameters['tab'],
    ),
    AppDestination.reports => const ReportsScreen(),
    AppDestination.settings => const SettingsScreen(),
    AppDestination.help => const HelpScreen(),
  };

  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          for (final d in AppDestination.values)
            GoRoute(
              path: d.path,
              pageBuilder: (context, state) =>
                  _fadePage(context, state, screenFor(d, state)),
            ),
        ],
      ),
    ],
  );
}

/// Transition courte en fondu, supprimée si les animations sont désactivées.
Page<void> _fadePage(BuildContext context, GoRouterState state, Widget child) {
  final animate = !MediaQuery.disableAnimationsOf(context);
  final duration = animate ? const Duration(milliseconds: 180) : Duration.zero;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );
}
