import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/domain/audit_status.dart';
import '../../settings/domain/app_settings.dart';

@immutable
class ReportStep {
  const ReportStep({
    required this.title,
    required this.target,
    required this.level,
    required this.status,
    this.done = false,
  });

  final String title;
  final String target;
  final String level;
  final String status;
  final bool done;
}

@immutable
class ReportFile {
  const ReportFile(this.path, this.label, this.at, {required this.created});
  final String path;
  final String label;
  final DateTime at;
  final bool created;
}

@immutable
class ReportCommand {
  const ReportCommand({
    required this.display,
    required this.status,
    this.exitCode,
    required this.at,
    required this.durationMs,
    this.isCheck = false,
  });

  /// Arguments déjà masqués par le journal.
  final String display;
  final String status;
  final int? exitCode;
  final DateTime at;
  final int durationMs;

  /// Test, analyse ou audit (rangé dans « Tests et audits »).
  final bool isCheck;
}

@immutable
class ReportDeliverable {
  const ReportDeliverable(this.path, this.size, this.sha256, this.signing);
  final String path;
  final String size;
  final String sha256;
  final String signing;
}

@immutable
class ReportAuditLine {
  const ReportAuditLine(this.status, this.label, this.fix);
  final AuditStatus status;
  final String label;
  final String fix;
}

@immutable
class ReportAudit {
  const ReportAudit(this.title, this.lines);
  final String title;
  final List<ReportAuditLine> lines;

  int count(AuditStatus s) => lines.where((l) => l.status == s).length;
}

@immutable
class ReportData {
  const ReportData({
    required this.language,
    required this.appVersion,
    required this.generatedAt,
    required this.projectName,
    required this.sessionVersion,
    required this.sessionStatus,
    required this.sessionCreated,
    this.sessionCompleted,
    required this.currentLevel,
    this.technologies = const [],
    this.targets = const [],
    this.steps = const [],
    this.files = const [],
    this.commands = const [],
    this.deliverables = const [],
    this.audits = const [],
    this.procedures = const {},
    this.glossary = const [],
  });

  final AppLanguage language;
  final String appVersion;
  final DateTime generatedAt;
  final String projectName;
  final String sessionVersion;
  final String sessionStatus;
  final DateTime sessionCreated;
  final DateTime? sessionCompleted;
  final String currentLevel;
  final List<String> technologies;
  final List<String> targets;
  final List<ReportStep> steps;
  final List<ReportFile> files;
  final List<ReportCommand> commands;
  final List<ReportDeliverable> deliverables;
  final List<ReportAudit> audits;

  /// Procédure manuelle de publication, par cible.
  final Map<String, List<String>> procedures;

  /// Termes du lexique cités par les étapes : (terme, définition).
  final List<(String, String)> glossary;

  int get doneSteps => steps.where((s) => s.done).length;
  List<ReportStep> get remaining => steps.where((s) => !s.done).toList();
  List<ReportCommand> get checks => commands.where((c) => c.isCheck).toList();
}

/// Procédure manuelle par cible (contenu pédagogique bilingue).
List<String> manualProcedure(String target, AppLanguage lang) {
  final fr = lang == AppLanguage.fr;
  return switch (target) {
    'android' =>
      fr
          ? [
              'Construire l\'App Bundle signé (flutter build appbundle --release) et vérifier son empreinte SHA-256.',
              'Dans la Play Console : créer l\'application, remplir la fiche, la sécurité des données et la classification.',
              'Envoyer le premier .aab à la main sur la piste de test interne ; les suivants peuvent passer par Fastlane.',
              'Ajouter des testeurs, déployer la version, puis promouvoir vers la production quand elle est validée.',
            ]
          : [
              'Build the signed App Bundle (flutter build appbundle --release) and check its SHA-256 fingerprint.',
              'In the Play Console: create the app, fill in the listing, data safety and content rating.',
              'Upload the first .aab by hand to the internal testing track; later ones can go through Fastlane.',
              'Add testers, roll out the release, then promote to production once validated.',
            ],
    'ios' =>
      fr
          ? [
              'Adhérer à l\'Apple Developer Program, enregistrer l\'identifiant et créer la fiche dans App Store Connect.',
              'Créer les secrets de la CI (clé API App Store Connect), pousser la configuration et lancer le build macOS.',
              'Quand le build apparaît dans TestFlight, ajouter des testeurs ; remplir la confidentialité de l\'app.',
              'Soumettre la version à la vérification d\'Apple depuis App Store Connect.',
            ]
          : [
              'Join the Apple Developer Program, register the identifier and create the record in App Store Connect.',
              'Create the CI secrets (App Store Connect API key), push the configuration and launch the macOS build.',
              'When the build shows in TestFlight, add testers; fill in App Privacy.',
              'Submit the release for Apple review from App Store Connect.',
            ],
    'web' =>
      fr
          ? [
              'Construire le site et vérifier l\'audit (SEO, liens, contenu mixte).',
              'Préparer la configuration de l\'hébergeur puis déployer une prévisualisation, et enfin la production.',
              'Saisir les enregistrements DNS chez le gestionnaire du domaine, attendre la propagation.',
              'Vérifier HTTPS, la redirection depuis HTTP et le site sur un vrai téléphone.',
            ]
          : [
              'Build the site and check the audit (SEO, links, mixed content).',
              'Prepare the host configuration, then deploy a preview, and finally production.',
              'Enter the DNS records at the domain provider, wait for propagation.',
              'Check HTTPS, the redirect from HTTP and the site on a real phone.',
            ],
    _ =>
      fr
          ? [
              'Construire la version release pour cette plateforme et la tester sur une machine propre.',
              'Choisir un canal de distribution (store, paquet, téléchargement) et suivre sa procédure.',
            ]
          : [
              'Build the release version for this platform and test it on a clean machine.',
              'Choose a distribution channel (store, package, download) and follow its procedure.',
            ],
  };
}

String _e(String v) => const HtmlEscape().convert(v);

String _date(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Rapport HTML autonome (aucune ressource externe), imprimable en PDF
/// depuis un navigateur. Tout le contenu est échappé.
String renderReportHtml(ReportData r) {
  final fr = r.language == AppLanguage.fr;
  String t(String f, String e) => fr ? f : e;
  final b = StringBuffer();
  void row(List<String> cells, {bool head = false}) {
    final tag = head ? 'th' : 'td';
    b.write('<tr>${cells.map((c) => '<$tag>$c</$tag>').join()}</tr>\n');
  }

  String status(AuditStatus s) => switch (s) {
    AuditStatus.ok => '<span class="ok">✓</span>',
    AuditStatus.warning => '<span class="warn">!</span>',
    AuditStatus.failure => '<span class="fail">✗</span>',
    AuditStatus.info => '<span class="info">i</span>',
  };

  b
    ..writeln('<!DOCTYPE html>')
    ..writeln('<html lang="${fr ? 'fr' : 'en'}">')
    ..writeln('<head>')
    ..writeln('<meta charset="utf-8">')
    ..writeln(
      '<meta name="viewport" content="width=device-width, initial-scale=1">',
    )
    ..writeln(
      '<title>${_e(t('Rapport LaunchPilot', 'LaunchPilot report'))} — ${_e(r.projectName)} ${_e(r.sessionVersion)}</title>',
    )
    ..writeln('<style>')
    ..writeln('''
body{font-family:system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;margin:0;color:#141833;background:#f6f7fd;line-height:1.5}
main{max-width:960px;margin:0 auto;padding:32px 24px}
header{background:linear-gradient(120deg,#0e1433,#3f4bd1);color:#fff;padding:28px 24px;border-radius:16px;margin-bottom:24px}
header h1{margin:0 0 4px;font-size:1.7rem}header p{margin:2px 0;opacity:.9}
section{background:#fff;border:1px solid #dde1ff;border-radius:14px;padding:18px 20px;margin:0 0 18px;break-inside:avoid}
h2{margin:0 0 12px;font-size:1.2rem;color:#3f4bd1}
table{width:100%;border-collapse:collapse;font-size:.92rem}th,td{text-align:left;padding:6px 8px;border-bottom:1px solid #eceefe;vertical-align:top}
th{background:#f1f2fd}code{font-family:ui-monospace,monospace;font-size:.85rem;word-break:break-all}
.ok{color:#1f7a5c;font-weight:700}.warn{color:#b45309;font-weight:700}.fail{color:#b91c1c;font-weight:700}.info{color:#6d28d9;font-weight:700}
.muted{color:#5b6080;font-size:.9rem}.pill{display:inline-block;padding:2px 10px;border-radius:999px;background:#eef0ff;margin:2px 4px 2px 0}
@media print{body{background:#fff}main{padding:0}header{-webkit-print-color-adjust:exact;print-color-adjust:exact}section{border-color:#ccc}}
''')
    ..writeln('</style>')
    ..writeln('</head>')
    ..writeln('<body><main>')
    ..writeln('<header><h1>${_e(r.projectName)} · ${_e(r.sessionVersion)}</h1>')
    ..writeln(
      '<p>${_e(t('Rapport de session LaunchPilot', 'LaunchPilot session report'))} — ${_e(_date(r.generatedAt))}</p>',
    )
    ..writeln(
      '<p>${_e(t('Avancement', 'Progress'))} : ${r.doneSteps} / ${r.steps.length} · ${_e(r.currentLevel)} · ${_e(r.sessionStatus)}</p></header>',
    );

  // Résumé
  b
    ..writeln('<section><h2>${_e(t('Résumé', 'Summary'))}</h2><table>')
    ..writeln(
      '<tr><th>${_e(t('Projet', 'Project'))}</th><td>${_e(r.projectName)}</td></tr>',
    )
    ..writeln(
      '<tr><th>${_e(t('Version', 'Version'))}</th><td>${_e(r.sessionVersion)}</td></tr>',
    )
    ..writeln(
      '<tr><th>${_e(t('Session ouverte le', 'Session opened on'))}</th><td>${_e(_date(r.sessionCreated))}</td></tr>',
    );
  if (r.sessionCompleted case final c?) {
    b.writeln(
      '<tr><th>${_e(t('Session close le', 'Session closed on'))}</th><td>${_e(_date(c))}</td></tr>',
    );
  }
  b.writeln('</table></section>');

  // Technologies et cibles
  b.writeln(
    '<section><h2>${_e(t('Technologies et cibles', 'Technologies and targets'))}</h2>',
  );
  b.writeln(
    '<p>${r.technologies.isEmpty ? _e(t('Aucune analyse enregistrée.', 'No analysis recorded.')) : r.technologies.map((x) => '<span class="pill">${_e(x)}</span>').join()}</p>',
  );
  b.writeln(
    '<p>${_e(t('Cibles retenues', 'Selected targets'))} : ${r.targets.isEmpty ? '—' : r.targets.map(_e).join(', ')}</p></section>',
  );

  // Livrables
  b.writeln(
    '<section><h2>${_e(t('Versions et livrables', 'Versions and deliverables'))}</h2>',
  );
  if (r.deliverables.isEmpty) {
    b.writeln(
      '<p class="muted">${_e(t('Aucun livrable trouvé dans le projet au moment du rapport.', 'No deliverable found in the project when the report was made.'))}</p>',
    );
  } else {
    b.writeln('<table>');
    row(
      [
        t('Fichier', 'File'),
        t('Taille', 'Size'),
        'SHA-256',
        t('Signature', 'Signing'),
      ].map(_e).toList(),
      head: true,
    );
    for (final d in r.deliverables) {
      row([
        '<code>${_e(d.path)}</code>',
        _e(d.size),
        '<code>${_e(d.sha256)}</code>',
        _e(d.signing),
      ]);
    }
    b.writeln('</table>');
  }
  b.writeln('</section>');

  // Fichiers modifiés
  b.writeln(
    '<section><h2>${_e(t('Fichiers créés ou modifiés par LaunchPilot', 'Files created or changed by LaunchPilot'))}</h2>',
  );
  if (r.files.isEmpty) {
    b.writeln(
      '<p class="muted">${_e(t('Aucun fichier modifié pendant cette session.', 'No file changed during this session.'))}</p>',
    );
  } else {
    b.writeln('<table>');
    row(
      [
        t('Fichier', 'File'),
        t('Action', 'Action'),
        t('Motif', 'Reason'),
        t('Date', 'Date'),
      ].map(_e).toList(),
      head: true,
    );
    for (final f in r.files) {
      row([
        '<code>${_e(f.path)}</code>',
        _e(f.created ? t('créé', 'created') : t('modifié', 'changed')),
        _e(f.label),
        _e(_date(f.at)),
      ]);
    }
    b.writeln('</table>');
  }
  b.writeln('</section>');

  // Commandes
  b.writeln(
    '<section><h2>${_e(t('Commandes exécutées (secrets masqués)', 'Commands run (secrets masked)'))}</h2>',
  );
  if (r.commands.isEmpty) {
    b.writeln(
      '<p class="muted">${_e(t('Aucune commande pendant cette session.', 'No command during this session.'))}</p>',
    );
  } else {
    b.writeln('<table>');
    row(
      [
        t('Commande', 'Command'),
        t('Résultat', 'Result'),
        t('Durée', 'Duration'),
        t('Date', 'Date'),
      ].map(_e).toList(),
      head: true,
    );
    for (final c in r.commands) {
      row([
        '<code>${_e(c.display)}</code>',
        _e('${c.status}${c.exitCode == null ? '' : ' (${c.exitCode})'}'),
        _e('${(c.durationMs / 1000).toStringAsFixed(1)} s'),
        _e(_date(c.at)),
      ]);
    }
    b.writeln('</table>');
  }
  b.writeln('</section>');

  // Tests et audits
  b.writeln(
    '<section><h2>${_e(t('Tests et audits', 'Tests and audits'))}</h2>',
  );
  if (r.checks.isEmpty) {
    b.writeln(
      '<p class="muted">${_e(t('Aucun test ni analyse lancé pendant cette session.', 'No test or analysis run during this session.'))}</p>',
    );
  } else {
    b.writeln('<ul>');
    for (final c in r.checks) {
      final ok = c.status == 'succeeded';
      b.writeln(
        '<li>${ok ? '<span class="ok">✓</span>' : '<span class="fail">✗</span>'} <code>${_e(c.display)}</code> — ${_e(c.status)}</li>',
      );
    }
    b.writeln('</ul>');
  }
  for (final a in r.audits) {
    b.writeln(
      '<h3>${_e(a.title)} — ${a.count(AuditStatus.failure)} ${_e(t('problème(s)', 'problem(s)'))}, ${a.count(AuditStatus.warning)} ${_e(t('avertissement(s)', 'warning(s)'))}</h3><table>',
    );
    for (final l in a.lines.where((l) => l.status != AuditStatus.ok)) {
      row([status(l.status), _e(l.label), _e(l.fix)]);
    }
    b.writeln('</table>');
  }
  b.writeln('</section>');

  // Actions restantes
  b.writeln(
    '<section><h2>${_e(t('Avertissements et actions restantes', 'Warnings and remaining actions'))}</h2>',
  );
  if (r.remaining.isEmpty) {
    b.writeln(
      '<p class="ok">${_e(t('Toutes les étapes de la checklist sont terminées.', 'All checklist steps are done.'))}</p>',
    );
  } else {
    b.writeln('<table>');
    row(
      [
        t('Étape', 'Step'),
        t('Cible', 'Target'),
        t('Niveau', 'Level'),
        t('Statut', 'Status'),
      ].map(_e).toList(),
      head: true,
    );
    for (final s in r.remaining) {
      row([_e(s.title), _e(s.target), _e(s.level), _e(s.status)]);
    }
    b.writeln('</table>');
  }
  b.writeln('</section>');

  // Procédure manuelle
  if (r.procedures.isNotEmpty) {
    b.writeln(
      '<section><h2>${_e(t('Procédure manuelle de publication', 'Manual publishing procedure'))}</h2>',
    );
    for (final e in r.procedures.entries) {
      b.writeln('<h3>${_e(e.key)}</h3><ol>');
      for (final step in e.value) {
        b.writeln('<li>${_e(step)}</li>');
      }
      b.writeln('</ol>');
    }
    b.writeln('</section>');
  }

  // Lexique
  if (r.glossary.isNotEmpty) {
    b.writeln('<section><h2>${_e(t('Lexique', 'Glossary'))}</h2><dl>');
    for (final (term, def) in r.glossary) {
      b.writeln('<dt><strong>${_e(term)}</strong></dt><dd>${_e(def)}</dd>');
    }
    b.writeln('</dl></section>');
  }

  b
    ..writeln(
      '<p class="muted">${_e(t('Généré par LaunchPilot', 'Generated by LaunchPilot'))} ${_e(r.appVersion)}. ${_e(t('Pour un PDF : ouvre ce fichier dans un navigateur, puis Imprimer → Enregistrer au format PDF.', 'For a PDF: open this file in a browser, then Print → Save as PDF.'))}</p>',
    )
    ..writeln('</main></body></html>');
  return b.toString();
}

/// Nom de fichier proposé : `rapport-projet-version-date.html`.
String reportFileName(String project, String version, DateTime at) {
  String slug(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9.+-]+'), '-')
      .replaceAll(RegExp('-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  final day =
      '${at.year}${at.month.toString().padLeft(2, '0')}${at.day.toString().padLeft(2, '0')}';
  return 'rapport-${slug(project)}-${slug(version)}-$day.html';
}
