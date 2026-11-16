import 'package:path/path.dart' as p;

import '../../detection/domain/detection_report.dart';
import '../domain/checklist_step.dart';
import '../domain/launch_target.dart';

/// Dossier (absolu) du manifeste d'un gestionnaire de paquets.
String manifestDir(ProjectInfo project, PackageManagerInfo pkg) {
  final dir = p.posix.dirname(pkg.manifest);
  return dir == '.' ? project.root : p.join(project.root, dir);
}

PackageManagerInfo? pubPackage(ProjectInfo project) =>
    project.report.packages.where((p) => p.manager == 'pub').firstOrNull;

PackageManagerInfo? nodePackage(ProjectInfo project) => project.report.packages
    .where((p) => const {'npm', 'pnpm', 'yarn', 'bun'}.contains(p.manager))
    .firstOrNull;

/// Commande lancée dans le dossier de [pkg] (ou à la racine).
CommandPreview command(
  ProjectInfo project,
  String executable,
  List<String> arguments, {
  PackageManagerInfo? pkg,
  String? comment,
}) => CommandPreview(
  executable: executable,
  arguments: arguments,
  workingDirectory: pkg == null ? project.root : manifestDir(project, pkg),
  comment: comment,
);
