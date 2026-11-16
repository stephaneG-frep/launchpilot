import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Origine d'une commande. Les actions de publication ne sont acceptées
/// que si elles viennent du flux dédié (récapitulatif et confirmation
/// renforcée) ; tapées dans le terminal, elles sont refusées.
enum CommandPurpose { general, deployment }

/// Commande à exécuter : exécutable et arguments séparés, jamais une chaîne
/// interprétée par un shell.
@immutable
class CommandSpec {
  const CommandSpec({
    required this.executable,
    this.arguments = const [],
    required this.workingDirectory,
    this.timeout = const Duration(minutes: 10),
    this.purpose = CommandPurpose.general,
  });

  final String executable;
  final List<String> arguments;
  final String workingDirectory;
  final Duration timeout;
  final CommandPurpose purpose;

  /// Représentation lisible, uniquement pour l'affichage.
  String get display => [
    executable,
    for (final a in arguments)
      a.isEmpty || a.contains(RegExp(r'''[\s"'$`\\]''')) ? jsonEncode(a) : a,
  ].join(' ');

  /// Empreinte liant une confirmation à cette commande exacte.
  String get digest => sha256
      .convert(
        utf8.encode(
          jsonEncode([executable, arguments, workingDirectory, purpose.name]),
        ),
      )
      .toString();
}

/// Niveau de risque, du plus sûr au plus dangereux.
enum RiskLevel {
  /// Ne modifie rien : peut s'exécuter même en mode simulation.
  readOnly,

  /// Écrit uniquement des fichiers générés dans le projet (build, cache,
  /// dépendances).
  local,

  /// Modifie le projet ou l'état Git : confirmation obligatoire.
  sensitive,

  /// Refusé par défaut (publication, push, suppression, système…).
  forbidden,
}

/// Raison d'une décision, traduite par l'interface.
enum PolicyIssue {
  notAllowlisted,
  shell,
  privileged,
  invalidExecutable,
  invalidArgument,
  outsideProject,
  workingDirectoryOutside,
  publication,
  gitPush,
  destructive,
  systemChange,
  globalInstall,
  remoteCode,
  unknownSubcommand,
  runsProjectScript,
  createsTag,

  /// Mise en ligne en production, par le flux dédié.
  productionDeploy,

  /// Mise en ligne sur une adresse de prévisualisation, par le flux dédié.
  previewDeploy,

  /// Interroge un site en ligne (audit Lighthouse).
  network,

  /// Envoi vers un store, par le flux dédié.
  storePublication,
}

@immutable
class PolicyDecision {
  const PolicyDecision(this.risk, [this.issues = const []]);

  final RiskLevel risk;
  final List<PolicyIssue> issues;

  bool get allowed => risk != RiskLevel.forbidden;

  /// Confirmation renforcée (récapitulatif à cocher) : création de tag,
  /// déploiement.
  bool get reinforced =>
      issues.contains(PolicyIssue.createsTag) ||
      issues.contains(PolicyIssue.productionDeploy) ||
      issues.contains(PolicyIssue.previewDeploy) ||
      issues.contains(PolicyIssue.storePublication);
}
