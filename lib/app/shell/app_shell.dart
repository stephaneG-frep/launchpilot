import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/launch_palette.dart';
import '../../features/settings/application/settings_controller.dart';
import '../destinations.dart';

/// Points de rupture de la navigation.
abstract final class Breakpoints {
  /// En dessous : barre d'application et tiroir.
  static const compact = 720.0;

  /// Au-dessus : barre latérale complète avec libellés.
  static const expanded = 1100.0;
}

/// Coque commune : fond dégradé, navigation adaptée à la largeur et
/// raccourcis clavier Ctrl+1 … Ctrl+0.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final current = AppDestination.fromLocation(location);
    final width = MediaQuery.sizeOf(context).width;
    void go(AppDestination d) => context.go(d.path);

    final shortcuts = <ShortcutActivator, VoidCallback>{
      for (final d in AppDestination.values)
        CtrlDigitActivator(int.parse(d.shortcutKey)): () => go(d),
    };

    final Widget body;
    if (width < Breakpoints.compact) {
      body = Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(current.label(context.l10n)),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              tooltip: context.l10n.navOpenMenu,
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        drawer: Drawer(
          child: SafeArea(
            child: SideNavigation(
              current: current,
              extended: true,
              onSelected: (d) {
                Navigator.of(context).pop();
                go(d);
              },
            ),
          ),
        ),
        body: child,
      );
    } else {
      body = Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            SideNavigation(
              current: current,
              extended: width >= Breakpoints.expanded,
              onSelected: go,
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    return CallbackShortcuts(
      bindings: shortcuts,
      child: FocusScope(autofocus: true, child: _Background(child: body)),
    );
  }
}

/// Ctrl + chiffre, reconnu par la position physique de la touche pour
/// fonctionner aussi en AZERTY (où « 1 » sans Maj produit « & »), ainsi
/// que par le pavé numérique.
class CtrlDigitActivator extends ShortcutActivator {
  const CtrlDigitActivator(this.digit) : assert(digit >= 0 && digit <= 9);

  final int digit;

  static const _row = [
    PhysicalKeyboardKey.digit0,
    PhysicalKeyboardKey.digit1,
    PhysicalKeyboardKey.digit2,
    PhysicalKeyboardKey.digit3,
    PhysicalKeyboardKey.digit4,
    PhysicalKeyboardKey.digit5,
    PhysicalKeyboardKey.digit6,
    PhysicalKeyboardKey.digit7,
    PhysicalKeyboardKey.digit8,
    PhysicalKeyboardKey.digit9,
  ];

  static const _numpad = [
    PhysicalKeyboardKey.numpad0,
    PhysicalKeyboardKey.numpad1,
    PhysicalKeyboardKey.numpad2,
    PhysicalKeyboardKey.numpad3,
    PhysicalKeyboardKey.numpad4,
    PhysicalKeyboardKey.numpad5,
    PhysicalKeyboardKey.numpad6,
    PhysicalKeyboardKey.numpad7,
    PhysicalKeyboardKey.numpad8,
    PhysicalKeyboardKey.numpad9,
  ];

  @override
  Iterable<LogicalKeyboardKey>? get triggers => null;

  @override
  bool accepts(KeyEvent event, HardwareKeyboard state) {
    if (event is! KeyDownEvent) return false;
    final key = event.physicalKey;
    return (key == _row[digit] || key == _numpad[digit]) &&
        state.isControlPressed &&
        !state.isAltPressed &&
        !state.isMetaPressed;
  }

  @override
  String debugDescribeKeys() => 'Ctrl+$digit';
}

class _Background extends StatelessWidget {
  const _Background({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = LaunchPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.backgroundTop, palette.backgroundBottom],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.9, -0.9),
            radius: 1.1,
            colors: [palette.glowViolet, Colors.transparent],
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.8, 1),
              radius: 0.9,
              colors: [palette.glowTurquoise, Colors.transparent],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Barre latérale : complète (libellés et groupes) ou compacte (icônes et
/// infobulles). Défilable pour rester utilisable sur une fenêtre basse.
class SideNavigation extends ConsumerWidget {
  const SideNavigation({
    super.key,
    required this.current,
    required this.extended,
    required this.onSelected,
  });

  final AppDestination current;
  final bool extended;
  final ValueChanged<AppDestination> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = LaunchPalette.of(context);
    final settings = ref.watch(settingsControllerProvider);

    final items = <Widget>[];
    NavGroup? group;
    for (final d in AppDestination.values) {
      if (d.group != group) {
        group = d.group;
        items.add(
          extended
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 6),
                  child: Text(
                    group.label(l10n).toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: Divider(),
                ),
        );
      }
      items.add(
        _NavItem(
          destination: d,
          selected: d == current,
          extended: extended,
          onTap: () => onSelected(d),
        ),
      );
    }

    return Container(
      width: extended ? 256 : 80,
      decoration: BoxDecoration(
        color: palette.glassFill,
        border: Border(right: BorderSide(color: palette.glassBorder)),
      ),
      child: Column(
        children: [
          _Brand(extended: extended),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 12),
              children: items,
            ),
          ),
          if (extended)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  Chip(
                    avatar: const Icon(Icons.school_outlined, size: 16),
                    label: Text(settings.explanationLevel.label(l10n)),
                    visualDensity: VisualDensity.compact,
                  ),
                  if (settings.demoMode)
                    Chip(
                      avatar: Icon(
                        Icons.science_outlined,
                        size: 16,
                        color: palette.accentOrange,
                      ),
                      label: Text(l10n.demoTag),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final logo = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BrandColors.turquoise,
            BrandColors.indigo,
            BrandColors.violet,
          ],
        ),
      ),
      child: const Icon(Icons.flight_takeoff, color: Colors.white, size: 22),
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(extended ? 20 : 20, 20, 16, 8),
      child: Row(
        children: [
          logo,
          if (extended) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.appTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    context.l10n.appTagline,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.extended,
    required this.onTap,
  });

  final AppDestination destination;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final label = destination.label(context.l10n);
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    final animate = !MediaQuery.disableAnimationsOf(context);

    final content = AnimatedContainer(
      duration: animate ? const Duration(milliseconds: 160) : Duration.zero,
      height: 44,
      padding: EdgeInsets.symmetric(horizontal: extended ? 14 : 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: selected
            ? scheme.primary.withValues(alpha: 0.14)
            : Colors.transparent,
        border: Border.all(
          color: selected
              ? scheme.primary.withValues(alpha: 0.35)
              : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisAlignment: extended
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          Icon(
            selected ? destination.selectedIcon : destination.icon,
            color: color,
            size: 22,
          ),
          if (extended) ...[
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        excludeSemantics: true,
        child: Tooltip(
          message: context.l10n.navShortcutTooltip(
            label,
            destination.shortcutKey,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              key: ValueKey('nav-${destination.name}'),
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
