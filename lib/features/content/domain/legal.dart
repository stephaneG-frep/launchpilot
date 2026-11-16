import 'package:flutter/foundation.dart';

import '../../detection/domain/detection_report.dart';
import '../../settings/domain/app_settings.dart';

/// Catégories de données personnelles susceptibles d'être traitées.
enum DataCategory {
  contact,
  location,
  photos,
  audio,
  contacts,
  usage,
  crashDiagnostics,
  advertisingId,
  payment,
}

enum PublisherType { individual, company }

/// Réponses au questionnaire. Rien n'est envoyé nulle part : elles servent
/// à remplir des modèles que l'utilisateur relit et adapte.
@immutable
class LegalAnswers {
  const LegalAnswers({
    this.appName = '',
    this.publisherType = PublisherType.individual,
    this.publisherName = '',
    this.address = '',
    this.email = '',
    this.companyId = '',
    this.hostName = '',
    this.hostAddress = '',
    this.data = const {},
    this.thirdParties = const [],
    this.retentionMonths = 12,
    this.usesCookies = false,
    this.allowsMinors = false,
  });

  final String appName;
  final PublisherType publisherType;
  final String publisherName;
  final String address;
  final String email;

  /// SIREN/SIRET ou équivalent (entreprises).
  final String companyId;
  final String hostName;
  final String hostAddress;
  final Set<DataCategory> data;
  final List<String> thirdParties;
  final int retentionMonths;
  final bool usesCookies;

  /// Public de moins de 15 ans.
  final bool allowsMinors;

  /// Champs indispensables encore vides (dans l'ordre du formulaire).
  List<String> get missing => [
    if (appName.trim().isEmpty) 'appName',
    if (publisherName.trim().isEmpty) 'publisherName',
    if (email.trim().isEmpty) 'email',
    if (hostName.trim().isEmpty) 'hostName',
  ];

  LegalAnswers copyWith({
    String? appName,
    PublisherType? publisherType,
    String? publisherName,
    String? address,
    String? email,
    String? companyId,
    String? hostName,
    String? hostAddress,
    Set<DataCategory>? data,
    List<String>? thirdParties,
    int? retentionMonths,
    bool? usesCookies,
    bool? allowsMinors,
  }) => LegalAnswers(
    appName: appName ?? this.appName,
    publisherType: publisherType ?? this.publisherType,
    publisherName: publisherName ?? this.publisherName,
    address: address ?? this.address,
    email: email ?? this.email,
    companyId: companyId ?? this.companyId,
    hostName: hostName ?? this.hostName,
    hostAddress: hostAddress ?? this.hostAddress,
    data: data ?? this.data,
    thirdParties: thirdParties ?? this.thirdParties,
    retentionMonths: retentionMonths ?? this.retentionMonths,
    usesCookies: usesCookies ?? this.usesCookies,
    allowsMinors: allowsMinors ?? this.allowsMinors,
  );

  Map<String, Object?> toJson() => {
    'appName': appName,
    'publisherType': publisherType.name,
    'publisherName': publisherName,
    'address': address,
    'email': email,
    'companyId': companyId,
    'hostName': hostName,
    'hostAddress': hostAddress,
    'data': [for (final d in data) d.name],
    'thirdParties': thirdParties,
    'retentionMonths': retentionMonths,
    'usesCookies': usesCookies,
    'allowsMinors': allowsMinors,
  };

  factory LegalAnswers.fromJson(Map<String, Object?> j) => LegalAnswers(
    appName: j['appName'] as String? ?? '',
    publisherType:
        PublisherType.values.asNameMap()[j['publisherType']] ??
        PublisherType.individual,
    publisherName: j['publisherName'] as String? ?? '',
    address: j['address'] as String? ?? '',
    email: j['email'] as String? ?? '',
    companyId: j['companyId'] as String? ?? '',
    hostName: j['hostName'] as String? ?? '',
    hostAddress: j['hostAddress'] as String? ?? '',
    data: {
      for (final d in (j['data'] as List? ?? const []))
        ?DataCategory.values.asNameMap()[d],
    },
    thirdParties: (j['thirdParties'] as List? ?? const []).cast<String>(),
    retentionMonths: j['retentionMonths'] as int? ?? 12,
    usesCookies: j['usesCookies'] as bool? ?? false,
    allowsMinors: j['allowsMinors'] as bool? ?? false,
  );

  /// Préremplissage d'après la détection : permissions, SDK et hébergement.
  /// L'utilisateur corrige ensuite ce qui ne correspond pas.
  factory LegalAnswers.fromDetection(DetectionReport r, {String appName = ''}) {
    final data = <DataCategory>{};
    for (final p in r.permissions) {
      final n = p.name.toUpperCase();
      if (n.contains('LOCATION')) data.add(DataCategory.location);
      if (n.contains('CAMERA') || n.contains('PHOTO')) {
        data.add(DataCategory.photos);
      }
      if (n.contains('RECORD_AUDIO') || n.contains('MICROPHONE')) {
        data.add(DataCategory.audio);
      }
      if (n.contains('CONTACTS')) data.add(DataCategory.contacts);
    }
    for (final s in r.services) {
      switch (s.kind) {
        case ServiceKind.analytics:
          data.add(DataCategory.usage);
        case ServiceKind.ads:
          data.addAll([DataCategory.advertisingId, DataCategory.usage]);
        case ServiceKind.crashReporting:
          data.add(DataCategory.crashDiagnostics);
        case ServiceKind.payments:
          data.add(DataCategory.payment);
        case ServiceKind.backend || ServiceKind.messaging:
          data.add(DataCategory.contact);
      }
    }
    final hosting = r.findingsOf(FindingCategory.hosting);
    final web = r.targetFor(PlatformTarget.web).detected;
    return LegalAnswers(
      appName: appName,
      data: data,
      thirdParties: [for (final s in r.services) s.label],
      hostName: hosting.isEmpty ? '' : (hosting.first.detail ?? ''),
      usesCookies:
          web &&
          r.services.any(
            (s) => s.kind == ServiceKind.analytics || s.kind == ServiceKind.ads,
          ),
    );
  }
}

/// Marque présente en tête de chaque modèle généré (commentaire invisible
/// une fois le Markdown ou le HTML affiché).
String legalTemplateNotice(AppLanguage lang) => lang == AppLanguage.fr
    ? '<!-- Modèle généré par LaunchPilot à partir de tes réponses. Il ne '
          'garantit pas la conformité juridique : relis-le, complète-le et '
          'fais-le valider si nécessaire. -->'
    : '<!-- Template generated by LaunchPilot from your answers. It does not '
          'guarantee legal compliance: review it, complete it and have it '
          'validated if needed. -->';

String _dataLabel(DataCategory d, bool fr) => switch (d) {
  DataCategory.contact =>
    fr
        ? 'données de contact (e-mail, identifiant de compte)'
        : 'contact data (email, account identifier)',
  DataCategory.location =>
    fr ? 'localisation de l\'appareil' : 'device location',
  DataCategory.photos =>
    fr ? 'photos et images issues de la caméra' : 'photos and camera images',
  DataCategory.audio => fr ? 'enregistrements audio' : 'audio recordings',
  DataCategory.contacts => fr ? 'carnet de contacts' : 'address book',
  DataCategory.usage =>
    fr ? 'données d\'utilisation (statistiques)' : 'usage data (analytics)',
  DataCategory.crashDiagnostics =>
    fr
        ? 'rapports de plantage et diagnostics'
        : 'crash reports and diagnostics',
  DataCategory.advertisingId =>
    fr ? 'identifiant publicitaire' : 'advertising identifier',
  DataCategory.payment =>
    fr
        ? 'informations de paiement (traitées par le prestataire de paiement)'
        : 'payment information (handled by the payment provider)',
};

String _or(String v, String placeholder) =>
    v.trim().isEmpty ? placeholder : v.trim();

/// Politique de confidentialité (Markdown).
String privacyPolicy(LegalAnswers a, AppLanguage lang, DateTime date) {
  final fr = lang == AppLanguage.fr;
  final app = _or(a.appName, fr ? '[NOM DE L\'APPLICATION]' : '[APP NAME]');
  final who = _or(
    a.publisherName,
    fr ? '[NOM DE L\'ÉDITEUR]' : '[PUBLISHER NAME]',
  );
  final email = _or(a.email, fr ? '[ADRESSE E-MAIL]' : '[EMAIL ADDRESS]');
  final day =
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  final b = StringBuffer()
    ..writeln(legalTemplateNotice(lang))
    ..writeln()
    ..writeln(
      fr ? '# Politique de confidentialité — $app' : '# Privacy policy — $app',
    )
    ..writeln()
    ..writeln(fr ? '_Dernière mise à jour : ${day}_' : '_Last updated: ${day}_')
    ..writeln()
    ..writeln(fr ? '## Responsable du traitement' : '## Data controller')
    ..writeln()
    ..writeln(
      fr
          ? '$app est éditée par $who. Pour toute question sur tes données, écris à $email.'
          : '$app is published by $who. For any question about your data, write to $email.',
    )
    ..writeln()
    ..writeln(fr ? '## Données collectées' : '## Data collected')
    ..writeln();
  if (a.data.isEmpty) {
    b.writeln(
      fr
          ? 'L\'application ne collecte aucune donnée personnelle.'
          : 'The app does not collect any personal data.',
    );
  } else {
    for (final d in DataCategory.values.where(a.data.contains)) {
      b.writeln('- ${_dataLabel(d, fr)}');
    }
    b
      ..writeln()
      ..writeln(
        fr
            ? 'Ces données servent uniquement au fonctionnement de l\'application et à son amélioration. Elles ne sont jamais vendues.'
            : 'This data is only used to run and improve the app. It is never sold.',
      );
  }
  b
    ..writeln()
    ..writeln(fr ? '## Services tiers' : '## Third-party services')
    ..writeln();
  if (a.thirdParties.isEmpty) {
    b.writeln(
      fr
          ? 'Aucun service tiers n\'est utilisé.'
          : 'No third-party service is used.',
    );
  } else {
    b.writeln(
      fr
          ? 'L\'application s\'appuie sur les services suivants, qui disposent de leur propre politique de confidentialité :'
          : 'The app relies on the following services, which have their own privacy policies:',
    );
    b.writeln();
    for (final t in a.thirdParties) {
      b.writeln('- $t');
    }
  }
  b
    ..writeln()
    ..writeln(fr ? '## Durée de conservation' : '## Retention')
    ..writeln()
    ..writeln(
      fr
          ? 'Les données sont conservées au maximum ${a.retentionMonths} mois, puis supprimées ou anonymisées.'
          : 'Data is kept for at most ${a.retentionMonths} months, then deleted or anonymized.',
    )
    ..writeln()
    ..writeln(fr ? '## Tes droits' : '## Your rights')
    ..writeln()
    ..writeln(
      fr
          ? 'Tu peux demander l\'accès, la rectification, l\'effacement ou la portabilité de tes données, ou t\'opposer à leur traitement, en écrivant à $email. Tu peux aussi introduire une réclamation auprès de l\'autorité de protection des données de ton pays (en France, la CNIL).'
          : 'You can request access, rectification, erasure or portability of your data, or object to its processing, by writing to $email. You can also lodge a complaint with your country\'s data protection authority.',
    );
  if (!a.allowsMinors) {
    b
      ..writeln()
      ..writeln(fr ? '## Mineurs' : '## Minors')
      ..writeln()
      ..writeln(
        fr
            ? 'L\'application ne s\'adresse pas aux enfants de moins de 15 ans.'
            : 'The app is not intended for children under 15.',
      );
  }
  return b.toString();
}

/// Mentions légales (Markdown).
String legalNotice(LegalAnswers a, AppLanguage lang) {
  final fr = lang == AppLanguage.fr;
  final company = a.publisherType == PublisherType.company;
  final b = StringBuffer()
    ..writeln(legalTemplateNotice(lang))
    ..writeln()
    ..writeln(fr ? '# Mentions légales' : '# Legal notice')
    ..writeln()
    ..writeln(fr ? '## Éditeur' : '## Publisher')
    ..writeln()
    ..writeln(
      '- ${fr ? 'Nom' : 'Name'} : ${_or(a.publisherName, fr ? '[NOM]' : '[NAME]')}',
    );
  if (company) {
    b.writeln(
      '- ${fr ? 'Identifiant (SIREN/SIRET)' : 'Company number'} : ${_or(a.companyId, fr ? '[NUMÉRO]' : '[NUMBER]')}',
    );
  }
  b
    ..writeln(
      '- ${fr ? 'Adresse' : 'Address'} : ${_or(a.address, fr ? '[ADRESSE]' : '[ADDRESS]')}',
    )
    ..writeln(
      '- ${fr ? 'Contact' : 'Contact'} : ${_or(a.email, fr ? '[E-MAIL]' : '[EMAIL]')}',
    )
    ..writeln()
    ..writeln(fr ? '## Hébergeur' : '## Host')
    ..writeln()
    ..writeln(
      '- ${_or(a.hostName, fr ? '[NOM DE L\'HÉBERGEUR]' : '[HOST NAME]')}',
    )
    ..writeln(
      '- ${_or(a.hostAddress, fr ? '[ADRESSE DE L\'HÉBERGEUR]' : '[HOST ADDRESS]')}',
    )
    ..writeln()
    ..writeln(fr ? '## Propriété intellectuelle' : '## Intellectual property')
    ..writeln()
    ..writeln(
      fr
          ? 'Les contenus de ${_or(a.appName, 'l\'application')} sont protégés. Toute reproduction sans autorisation est interdite.'
          : 'The content of ${_or(a.appName, 'the app')} is protected. Any reproduction without permission is prohibited.',
    );
  return b.toString();
}

/// Bannière de consentement minimale (HTML + JavaScript, sans dépendance).
/// Les scripts de mesure d'audience ne doivent être chargés qu'après
/// acceptation : voir le commentaire dans le modèle.
String cookieBanner(LegalAnswers a, AppLanguage lang) {
  final fr = lang == AppLanguage.fr;
  final text = fr
      ? 'Ce site utilise des cookies de mesure d\'audience. Tu peux les accepter ou les refuser.'
      : 'This site uses audience measurement cookies. You can accept or refuse them.';
  final accept = fr ? 'Accepter' : 'Accept';
  final refuse = fr ? 'Refuser' : 'Refuse';
  final more = fr ? 'En savoir plus' : 'Learn more';
  return '''${legalTemplateNotice(lang)}
<div id="lp-consent" role="dialog" aria-live="polite" hidden
     style="position:fixed;inset:auto 16px 16px 16px;max-width:560px;margin:auto;padding:16px;border-radius:12px;background:#141b3d;color:#fff;font:15px/1.4 system-ui,sans-serif;box-shadow:0 8px 24px rgba(0,0,0,.3)">
  <p style="margin:0 0 12px">$text <a href="privacy-policy.html" style="color:#2dd4bf">$more</a></p>
  <button type="button" data-consent="refuse">$refuse</button>
  <button type="button" data-consent="accept">$accept</button>
</div>
<script>
  (function () {
    var KEY = 'lp-consent';
    var box = document.getElementById('lp-consent');
    function apply(choice) {
      if (choice === 'accept') {
        // ${fr ? 'Charger ici les scripts de mesure d\'audience, et seulement ici.' : 'Load audience measurement scripts here, and only here.'}
      }
    }
    var saved = localStorage.getItem(KEY);
    if (saved) { apply(saved); return; }
    box.hidden = false;
    box.addEventListener('click', function (e) {
      var choice = e.target.getAttribute('data-consent');
      if (!choice) return;
      localStorage.setItem(KEY, choice);
      box.hidden = true;
      apply(choice);
    });
  })();
</script>
''';
}
