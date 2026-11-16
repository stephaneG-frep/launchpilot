import 'package:flutter/foundation.dart';

import '../../../core/domain/action_level.dart';
import '../../../core/domain/step_status.dart';

/// Aperçu d'une commande : exécutable et arguments séparés, jamais une
/// chaîne shell. L'exécution réelle passera par le `CommandRunner` (phase 5).
@immutable
class CommandPreview {
  const CommandPreview({
    required this.executable,
    this.arguments = const [],
    this.workingDirectory,
    this.comment,
  });

  final String executable;
  final List<String> arguments;
  final String? workingDirectory;

  /// Explication courte affichée au-dessus de la commande en mode Débutant.
  final String? comment;

  /// Représentation lisible, uniquement pour l'affichage.
  String get display => [
    executable,
    ...arguments.map((a) => a.contains(' ') ? '"$a"' : a),
  ].join(' ');
}

/// Comment une étape se termine.
enum StepKind {
  /// Exécute des commandes (via le moteur sécurisé) ; le résultat fixe le statut.
  command,

  /// Vérification ou action faite par l'utilisateur, qui la déclare faite.
  manual,

  /// Explication à lire : « J'ai compris ».
  pedagogical,
}

/// Étape de checklist telle que décrite dans le cahier des charges (§ 4).
@immutable
class ChecklistStep {
  const ChecklistStep({
    required this.id,
    required this.level,
    required this.title,
    required this.objective,
    required this.explanation,
    required this.whyRequired,
    this.affectedFiles = const [],
    this.commands = const [],
    required this.expectedResult,
    this.risks = const [],
    required this.verificationMethod,
    this.rollbackMethod,
    this.requiresConfirmation = false,
    this.isReversible = true,
    this.status = StepStatus.todo,
    this.targetId = 'common',
    this.kind = StepKind.manual,
    this.dependsOn = const [],
    this.summary,
    this.glossary = const [],
    this.laterPhase,
    this.toolTab,
  });

  final String id;
  final ActionLevel level;
  final String title;
  final String objective;
  final String explanation;
  final String whyRequired;
  final List<String> affectedFiles;
  final List<CommandPreview> commands;
  final String expectedResult;
  final List<String> risks;
  final String verificationMethod;
  final String? rollbackMethod;
  final bool requiresConfirmation;
  final bool isReversible;
  final StepStatus status;

  /// Cible (plugin) qui a produit l'étape : `common`, `android`…
  final String targetId;
  final StepKind kind;

  /// Identifiants des étapes à terminer avant celle-ci.
  final List<String> dependsOn;

  /// Explication condensée pour le mode Accompagné (sinon [objective]).
  final String? summary;

  /// Identifiants de termes du lexique utiles pour comprendre l'étape.
  final List<String> glossary;

  /// Phase où l'automatisation de cette étape arrivera ; d'ici là, elle se
  /// fait à la main en suivant les explications.
  final int? laterPhase;

  /// Outil de l'écran Contenus qui réalise l'étape (`/content?tab=…`).
  final String? toolTab;

  ChecklistStep withStatus(StepStatus value) => ChecklistStep(
    id: id,
    level: level,
    title: title,
    objective: objective,
    explanation: explanation,
    whyRequired: whyRequired,
    affectedFiles: affectedFiles,
    commands: commands,
    expectedResult: expectedResult,
    risks: risks,
    verificationMethod: verificationMethod,
    rollbackMethod: rollbackMethod,
    requiresConfirmation: requiresConfirmation,
    isReversible: isReversible,
    status: value,
    targetId: targetId,
    kind: kind,
    dependsOn: dependsOn,
    summary: summary,
    glossary: glossary,
    laterPhase: laterPhase,
    toolTab: toolTab,
  );
}
