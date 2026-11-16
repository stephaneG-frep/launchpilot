import 'package:flutter/foundation.dart';

import '../../detection/domain/detection_report.dart';
import '../../settings/domain/app_settings.dart';
import 'checklist_step.dart';

/// Ce qu'une cible peut savoir du projet pour bâtir sa checklist.
@immutable
class ProjectInfo {
  const ProjectInfo({
    required this.root,
    required this.report,
    required this.selectedTargets,
    required this.language,
    this.version,
  });

  final String root;
  final DetectionReport report;

  /// Identifiants des cibles retenues par l'utilisateur (`android`, `web`…).
  final Set<String> selectedTargets;
  final AppLanguage language;

  /// Version préparée dans la session, si connue.
  final String? version;

  bool hasTech(String id) => report.technologies.any((t) => t.id == id);

  /// Texte dans la langue de l'interface.
  String t(String fr, String en) => language == AppLanguage.fr ? fr : en;
}

/// Cible de publication enfichable (spec § 6.10). Le moteur ne connaît que
/// cette interface : ajouter Snap, Flathub ou le Microsoft Store revient à
/// écrire une nouvelle classe et à l'enregistrer, sans modifier le moteur.
abstract interface class LaunchTarget {
  /// Identifiant stable, préfixe des identifiants d'étapes (`android.build`).
  String get id;

  String label(AppLanguage language);

  /// Cible toujours active (tronc commun) ou seulement si retenue.
  bool get alwaysActive;

  Future<TargetDetection?> detect(ProjectInfo project);

  Future<List<ChecklistStep>> buildChecklist(ProjectInfo project);
}
