import 'package:flutter/foundation.dart';

import '../../../core/domain/step_status.dart';
import '../../checklist/domain/checklist_step.dart';
import '../../commands/domain/command_result.dart';
import '../../detection/domain/detection_report.dart';
import '../../llm/domain/prompt_builder.dart';

enum ChatRole { user, assistant }

@immutable
class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.text,
    this.followUps = const [],
    this.model,
    required this.at,
  });

  final ChatRole role;
  final String text;

  /// Questions de relance proposées par l'assistant.
  final List<String> followUps;

  /// Modèle ayant répondu (réponses de l'assistant).
  final String? model;
  final DateTime at;

  Map<String, Object?> toJson() => {
    'role': role.name,
    'text': text,
    'followUps': followUps,
    'model': model,
    'at': at.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, Object?> j) => ChatMessage(
    role:
        ChatRole.values.where((r) => r.name == j['role']).firstOrNull ??
        ChatRole.user,
    text: '${j['text'] ?? ''}',
    followUps: [for (final f in (j['followUps'] as List?) ?? const []) '$f'],
    model: j['model'] as String?,
    at: DateTime.tryParse('${j['at']}') ?? DateTime(2000),
  );
}

/// Éléments de contexte que l'utilisateur choisit d'envoyer.
enum ChatContext { project, checklist, lastCommand }

abstract final class ChatPrompt {
  static const schemaName = 'launchpilot_chat';

  static const schema = <String, Object?>{
    'type': 'object',
    'additionalProperties': false,
    'required': ['answer', 'followUps'],
    'properties': {
      'answer': {'type': 'string'},
      'followUps': {
        'type': 'array',
        'items': {'type': 'string'},
      },
    },
  };

  /// Nombre de messages précédents rappelés au modèle.
  static const historyLength = 6;

  /// Nombre de messages conservés dans la session.
  static const keptMessages = 40;

  static String system(String languageName) =>
      'Tu es LaunchPilot, un assistant pédagogique qui aide à préparer et '
      'publier des applications. Réponds en $languageName, simplement, en '
      'quelques paragraphes courts. Tu ne peux exécuter aucune commande ni '
      'modifier aucun fichier : si une commande est utile, écris-la comme un '
      'exemple et rappelle qu\'elle passera par l\'aperçu sécurisé de '
      'LaunchPilot. Ne demande jamais de clé, de mot de passe ni de fichier de '
      'signature. Si tu n\'es pas sûr, dis-le. Propose au plus trois questions '
      'de relance courtes dans followUps.';
}

/// Résumé du projet : aucun chemin absolu, aucun contenu de fichier.
String projectSummary({
  required String name,
  String? version,
  String? level,
  DetectionReport? report,
  Set<PlatformTarget> targets = const {},
}) => [
  'Projet : $name',
  if (version != null) 'Version en préparation : $version',
  if (level != null) 'Niveau en cours : $level',
  if (report != null) ...[
    'Technologies : ${report.technologies.map((t) => t.label).join(', ')}',
    'Gestionnaires de paquets : ${report.packages.map((p) => p.manager).toSet().join(', ')}',
    if (report.services.isNotEmpty)
      'Services détectés : ${report.services.map((s) => s.label).join(', ')}',
  ],
  if (targets.isNotEmpty)
    'Cibles retenues : ${targets.map((t) => t.name).join(', ')}',
].join('\n');

/// État de la checklist : avancement, échecs et prochaines étapes.
String checklistSummary(
  List<ChecklistStep> steps, {
  required bool Function(ChecklistStep) isDone,
  required bool Function(ChecklistStep) isBlocked,
}) {
  final done = steps.where(isDone).length;
  final failed = steps.where((s) => s.status == StepStatus.failed).toList();
  final next = steps.where((s) => !isDone(s) && !isBlocked(s)).take(3).toList();
  return [
    'Avancement : $done étapes terminées sur ${steps.length}',
    if (failed.isNotEmpty)
      'En échec : ${failed.map((s) => s.title).join(' ; ')}',
    if (next.isNotEmpty) 'Étapes disponibles :',
    for (final s in next) '- ${s.title} : ${s.objective}',
  ].join('\n');
}

/// Dernière commande (arguments et sortie déjà masqués par le moteur).
String commandSummary(CommandResult r, {int lines = 30}) {
  final tail = r.lines.length > lines
      ? r.lines.sublist(r.lines.length - lines)
      : r.lines;
  return [
    'Commande : ${r.spec.display}',
    'Statut : ${r.status.name}${r.exitCode == null ? '' : ' (code ${r.exitCode})'}',
    if (tail.isNotEmpty) 'Dernières lignes :',
    for (final l in tail)
      '${l.stream == OutputStream.stderr ? '[erreur] ' : ''}${l.text}',
  ].join('\n');
}

/// Conversation récente, pour garder le fil.
String historySummary(List<ChatMessage> messages, {required String you}) {
  final recent = messages.length > ChatPrompt.historyLength
      ? messages.sublist(messages.length - ChatPrompt.historyLength)
      : messages;
  return [
    for (final m in recent)
      '${m.role == ChatRole.user ? you : 'LaunchPilot'} : ${m.text}',
  ].join('\n');
}

/// Éléments transmis avec la question, dans l'ordre affiché à l'aperçu.
List<ContextItem> chatItems({
  String? project,
  String? checklist,
  String? lastCommand,
  String? history,
}) => [
  if (history != null && history.isNotEmpty)
    ContextItem(label: 'Conversation récente', content: history),
  if (project != null) ContextItem(label: 'Projet', content: project),
  if (checklist != null) ContextItem(label: 'Checklist', content: checklist),
  if (lastCommand != null)
    ContextItem(label: 'Dernière commande', content: lastCommand),
];
