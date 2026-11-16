import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/core/domain/audit_status.dart';
import 'package:launchpilot/core/domain/step_status.dart';
import 'package:launchpilot/core/domain/action_level.dart';
import 'package:launchpilot/features/agent_chat/domain/chat.dart';
import 'package:launchpilot/features/checklist/domain/checklist_step.dart';
import 'package:launchpilot/features/commands/domain/command_result.dart';
import 'package:launchpilot/features/commands/domain/command_spec.dart';
import 'package:launchpilot/features/help/domain/manual.dart';
import 'package:launchpilot/features/reports/domain/report.dart';
import 'package:launchpilot/features/settings/domain/app_settings.dart';

ReportData sample({String name = 'Météo'}) => ReportData(
  language: AppLanguage.fr,
  appVersion: '1.0.0',
  generatedAt: DateTime(2026, 11, 16, 10, 30),
  projectName: name,
  sessionVersion: '1.2.0',
  sessionStatus: 'Session en cours',
  sessionCreated: DateTime(2026, 11, 1),
  currentLevel: 'Préparer',
  technologies: const ['Flutter', 'Dart'],
  targets: const ['android', 'web'],
  steps: const [
    ReportStep(
      title: 'Vérifier Git',
      target: 'common',
      level: 'Analyser',
      status: 'Réussi',
      done: true,
    ),
    ReportStep(
      title: 'Mettre en ligne',
      target: 'web',
      level: 'Publier',
      status: 'À faire',
    ),
  ],
  files: [
    ReportFile(
      'pubspec.yaml',
      'Version 1.2.0',
      DateTime(2026, 11, 2),
      created: false,
    ),
  ],
  commands: [
    ReportCommand(
      display: 'flutter test',
      status: 'succeeded',
      exitCode: 0,
      at: DateTime(2026, 11, 3),
      durationMs: 4200,
      isCheck: true,
    ),
    ReportCommand(
      display: 'git status',
      status: 'succeeded',
      exitCode: 0,
      at: DateTime(2026, 11, 3),
      durationMs: 80,
    ),
  ],
  deliverables: const [
    ReportDeliverable(
      'build/app.aab',
      '42,1 Mo',
      'abc123',
      'Signé avec ta clé.',
    ),
  ],
  audits: const [
    ReportAudit('Web', [
      ReportAuditLine(
        AuditStatus.failure,
        'Meta description',
        'Ajoute une description.',
      ),
      ReportAuditLine(AuditStatus.ok, 'Titre', ''),
    ]),
  ],
  procedures: {'web': manualProcedure('web', AppLanguage.fr)},
  glossary: const [('SEO', 'Référencement naturel.')],
);

void main() {
  group('rapport HTML', () {
    test('sections attendues, autonome et imprimable', () {
      final html = renderReportHtml(sample());
      for (final part in [
        '<!DOCTYPE html>',
        'Résumé',
        'Technologies et cibles',
        'Versions et livrables',
        'Fichiers créés ou modifiés par LaunchPilot',
        'Commandes exécutées (secrets masqués)',
        'Tests et audits',
        'Avertissements et actions restantes',
        'Procédure manuelle de publication',
        'Lexique',
        '@media print',
        'Enregistrer au format PDF',
      ]) {
        expect(html, contains(part), reason: part);
      }
      expect(html, contains('1 / 2'));
      expect(html, contains('Mettre en ligne'));
      expect(html, contains('<code>abc123</code>'));
      // Aucune ressource externe.
      expect(html, isNot(contains('<script')));
      expect(html, isNot(contains('http://')));
      expect(html, isNot(contains('<link')));
    });

    test('tout le contenu est échappé', () {
      final html = renderReportHtml(
        sample(name: '<script>alert(1)</script> & "co"'),
      );
      expect(html, isNot(contains('<script>alert(1)</script>')));
      expect(html, contains('&lt;script&gt;alert(1)&lt;&#47;script&gt;'));
    });

    test('version anglaise', () {
      final data = sample();
      final en = ReportData(
        language: AppLanguage.en,
        appVersion: data.appVersion,
        generatedAt: data.generatedAt,
        projectName: data.projectName,
        sessionVersion: data.sessionVersion,
        sessionStatus: 'Active session',
        sessionCreated: data.sessionCreated,
        currentLevel: 'Prepare',
      );
      final html = renderReportHtml(en);
      expect(html, contains('<html lang="en">'));
      expect(
        html,
        contains('Remaining'.isEmpty ? '' : 'Warnings and remaining actions'),
      );
      expect(html, contains('No deliverable found'));
    });

    test('nom de fichier', () {
      expect(
        reportFileName('Météo Express', '1.2.0+7', DateTime(2026, 11, 16)),
        'rapport-m-t-o-express-1.2.0+7-20261116.html',
      );
    });

    test('procédures par cible', () {
      expect(
        manualProcedure('android', AppLanguage.fr).first,
        contains('App Bundle'),
      );
      expect(
        manualProcedure('ios', AppLanguage.en).first,
        contains('Apple Developer Program'),
      );
      expect(manualProcedure('linux', AppLanguage.fr), hasLength(2));
    });
  });

  group('chat', () {
    ChecklistStep step(
      String id,
      String title, {
      StepStatus status = StepStatus.todo,
    }) => ChecklistStep(
      id: id,
      level: ActionLevel.prepare,
      title: title,
      objective: 'Objectif de $title',
      explanation: '',
      whyRequired: '',
      expectedResult: '',
      verificationMethod: '',
      status: status,
    );

    test('résumé du projet sans chemin', () {
      final s = projectSummary(
        name: 'Météo',
        version: '1.2.0',
        level: 'Préparer',
      );
      expect(s, contains('Projet : Météo'));
      expect(s, contains('1.2.0'));
      expect(s, isNot(contains('/home')));
    });

    test('checklist : avancement, échecs, étapes disponibles', () {
      final steps = [
        step('a', 'Git', status: StepStatus.succeeded),
        step('b', 'Build', status: StepStatus.failed),
        step('c', 'Fiche'),
      ];
      final s = checklistSummary(
        steps,
        isDone: (x) => x.status == StepStatus.succeeded,
        isBlocked: (x) => false,
      );
      expect(s, contains('1 étapes terminées sur 3'));
      expect(s, contains('En échec : Build'));
      expect(s, contains('- Fiche : Objectif de Fiche'));
    });

    test('dernière commande : 30 dernières lignes, erreurs signalées', () {
      final r = CommandResult(
        spec: const CommandSpec(
          executable: 'flutter',
          arguments: ['build', 'apk'],
          workingDirectory: '/p',
        ),
        decision: const PolicyDecision(RiskLevel.local),
        status: RunStatus.failed,
        exitCode: 1,
        lines: [
          for (var i = 0; i < 40; i++)
            OutputLine(OutputStream.stdout, 'ligne $i'),
          const OutputLine(OutputStream.stderr, 'Gradle a échoué'),
        ],
      );
      final s = commandSummary(r);
      expect(s, contains('Commande : flutter build apk'));
      expect(s, contains('failed (code 1)'));
      expect(s, isNot(contains('ligne 5\n')));
      expect(s, contains('[erreur] Gradle a échoué'));
    });

    test('historique limité et éléments dans l\'ordre', () {
      final messages = [
        for (var i = 0; i < 10; i++)
          ChatMessage(
            role: i.isEven ? ChatRole.user : ChatRole.assistant,
            text: 'm$i',
            at: DateTime(2026),
          ),
      ];
      final h = historySummary(messages, you: 'Toi');
      expect(h.split('\n'), hasLength(ChatPrompt.historyLength));
      expect(h, startsWith('Toi : m4'));
      final items = chatItems(history: h, project: 'P', lastCommand: 'C');
      expect(items.map((i) => i.label), [
        'Conversation récente',
        'Projet',
        'Dernière commande',
      ]);
      expect(chatItems(), isEmpty);
    });

    test('message : aller-retour JSON', () {
      final m = ChatMessage(
        role: ChatRole.assistant,
        text: 'Bonjour',
        followUps: const ['Et ensuite ?'],
        model: 'claude-opus-5-5',
        at: DateTime(2026, 11, 16),
      );
      final back = ChatMessage.fromJson(m.toJson());
      expect(back.role, ChatRole.assistant);
      expect(back.followUps, ['Et ensuite ?']);
      expect(back.model, 'claude-opus-5-5');
      expect(ChatPrompt.system('français'), contains('aucune commande'));
      expect((ChatPrompt.schema['required']! as List), ['answer', 'followUps']);
    });
  });

  test('mode d\'emploi : chapitres et recherche, FR et EN', () {
    final fr = Manual.forLanguage(AppLanguage.fr);
    final en = Manual.forLanguage(AppLanguage.en);
    expect(fr.map((s) => s.id), en.map((s) => s.id));
    expect(
      fr.map((s) => s.id),
      containsAll([
        'start',
        'terminal',
        'android',
        'ios',
        'chat',
        'reports',
        'backup',
        'troubleshooting',
      ]),
    );
    expect(
      fr.where((s) => s.matches('trousseau')).map((s) => s.id),
      containsAll(['backup', 'troubleshooting']),
    );
    expect(fr.where((s) => s.matches('')).length, fr.length);
    for (final s in [...fr, ...en]) {
      expect(s.paragraphs, isNotEmpty, reason: s.id);
    }
  });
}
