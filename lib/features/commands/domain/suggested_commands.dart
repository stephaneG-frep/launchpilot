import 'package:path/path.dart' as p;

import '../../detection/domain/detection_report.dart';
import 'command_spec.dart';

/// Commandes utiles déduites du rapport de détection. Elles passent ensuite,
/// comme toute commande, par la politique et l'aperçu.
List<CommandSpec> suggestedCommands({
  required String root,
  required DetectionReport? report,
  Set<PlatformTarget> selectedTargets = const {},
}) {
  String dirOf(String manifest) {
    final dir = p.posix.dirname(manifest);
    return dir == '.' ? root : p.join(root, dir);
  }

  CommandSpec spec(String exe, List<String> args, String wd) =>
      CommandSpec(executable: exe, arguments: args, workingDirectory: wd);

  final out = <CommandSpec>[];
  if (report == null || report.git.present) {
    out
      ..add(spec('git', const ['status'], root))
      ..add(spec('git', const ['log', '--oneline', '-n', '20'], root));
  }
  if (report == null) return out;

  final isFlutter = report.technologies.any((t) => t.id == 'flutter');
  for (final pkg in report.packages) {
    final wd = dirOf(pkg.manifest);
    switch (pkg.manager) {
      case 'pub' when isFlutter:
        out.addAll([
          spec('flutter', const ['doctor', '-v'], wd),
          spec('flutter', const ['pub', 'get'], wd),
          spec('flutter', const ['analyze'], wd),
          spec('flutter', const ['test'], wd),
          for (final t in selectedTargets)
            ?switch (t) {
              PlatformTarget.android => spec('flutter', const [
                'build',
                'appbundle',
                '--release',
              ], wd),
              PlatformTarget.web => spec('flutter', const [
                'build',
                'web',
                '--release',
              ], wd),
              PlatformTarget.linux => spec('flutter', const [
                'build',
                'linux',
                '--release',
              ], wd),
              PlatformTarget.windows ||
              PlatformTarget.macos ||
              PlatformTarget.ios => null,
            },
        ]);
      case 'pub':
        out
          ..add(spec('dart', const ['pub', 'get'], wd))
          ..add(spec('dart', const ['analyze'], wd));
      case 'npm' || 'pnpm' || 'yarn' || 'bun':
        out.add(spec(pkg.manager, const ['install'], wd));
        for (final script in pkg.scripts.keys) {
          out.add(spec(pkg.manager, ['run', script], wd));
        }
    }
  }
  return out;
}
