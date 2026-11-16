import 'package:flutter/foundation.dart';

/// Catégorie de secret détectée, affichée à l'utilisateur sans la valeur.
enum SecretKind {
  apiKey,
  privateKey,
  jwt,
  password,
  token,
  connectionString,
  envSecret,
}

@immutable
class RedactionResult {
  const RedactionResult(this.text, this.counts);

  final String text;
  final Map<SecretKind, int> counts;

  int get total => counts.values.fold(0, (a, b) => a + b);
}

/// Masque les secrets dans un texte avant affichage, journalisation ou envoi
/// à un LLM. Les motifs privilégient la sécurité : un faux positif masque un
/// peu trop, un faux négatif ferait fuiter une clé.
abstract final class SecretRedactor {
  static const mask = '[SECRET MASQUÉ]';

  static final _rules = <(SecretKind, RegExp, int?)>[
    // Blocs de clé privée PEM (SSH, TLS, signature).
    (
      SecretKind.privateKey,
      RegExp(
        r'-----BEGIN [A-Z0-9 ]*PRIVATE KEY-----[\s\S]*?-----END [A-Z0-9 ]*PRIVATE KEY-----',
      ),
      null,
    ),
    // Chaînes de connexion avec identifiants : scheme://user:pass@host
    (
      SecretKind.connectionString,
      RegExp(r'\b[a-zA-Z][a-zA-Z0-9+.\-]*://[^\s:/@]+:[^\s@/]+@'),
      null,
    ),
    // Clés de fournisseurs connus.
    (SecretKind.apiKey, RegExp(r'\bsk-ant-[A-Za-z0-9_\-]{10,}'), null),
    (SecretKind.apiKey, RegExp(r'\bsk-[A-Za-z0-9_\-]{16,}'), null),
    (SecretKind.apiKey, RegExp(r'\bAIza[0-9A-Za-z_\-]{30,}'), null),
    (SecretKind.apiKey, RegExp(r'\b(?:AKIA|ASIA)[0-9A-Z]{16}\b'), null),
    (
      SecretKind.token,
      RegExp(r'\b(?:ghp|gho|ghu|ghs|ghr|github_pat)_[A-Za-z0-9_]{20,}'),
      null,
    ),
    (SecretKind.token, RegExp(r'\bxox[abprs]-[A-Za-z0-9\-]{10,}'), null),
    (SecretKind.token, RegExp(r'\bglpat-[A-Za-z0-9_\-]{20,}'), null),
    (
      SecretKind.jwt,
      RegExp(
        r'\beyJ[A-Za-z0-9_\-]{8,}\.[A-Za-z0-9_\-]{8,}\.[A-Za-z0-9_\-]{8,}',
      ),
      null,
    ),
    // En-têtes d'autorisation.
    (
      SecretKind.token,
      RegExp(
        r'\b(?:bearer|basic)\s+[A-Za-z0-9._~+/\-]{12,}=*',
        caseSensitive: false,
      ),
      null,
    ),
    // Affectations clé=valeur : seule la valeur (groupe 1) est masquée.
    (
      SecretKind.password,
      RegExp(
        r'''\b(?:[a-z0-9_.\-]*password|passwd|pwd|passphrase|storePassword|keyPassword)\b["']?\s*[:=]\s*["']?([^\s"',;]+)''',
        caseSensitive: false,
      ),
      1,
    ),
    (
      SecretKind.envSecret,
      RegExp(
        r'''\b[a-z0-9_.\-]*(?:secret|token|api[_\-]?key|apikey|access[_\-]?key|private[_\-]?key|client[_\-]?secret|auth)[a-z0-9_.\-]*\b["']?\s*[:=]\s*["']?([^\s"',;]{6,})''',
        caseSensitive: false,
      ),
      1,
    ),
  ];

  static RedactionResult redact(String input) {
    var text = input;
    final counts = <SecretKind, int>{};
    for (final (kind, pattern, group) in _rules) {
      text = text.replaceAllMapped(pattern, (m) {
        final value = group == null ? m[0]! : m[group];
        // Déjà masqué (y compris le début du masque, coupé à l'espace).
        if (value == null || value.contains(mask) || mask.startsWith(value)) {
          return m[0]!;
        }
        counts[kind] = (counts[kind] ?? 0) + 1;
        if (group == null) return mask;
        final whole = m[0]!;
        final start = whole.lastIndexOf(value);
        return whole.replaceRange(start, start + value.length, mask);
      });
    }
    return RedactionResult(text, counts);
  }

  /// Masque en plus des valeurs connues (par exemple la clé API utilisée
  /// pour la requête en cours), même si aucun motif ne les reconnaît.
  static String redactKnown(String input, Iterable<String> secrets) {
    var text = redact(input).text;
    for (final s in secrets) {
      if (s.length >= 6) text = text.replaceAll(s, mask);
    }
    return text;
  }

  /// Fichiers dont le contenu ne doit jamais être transmis, même masqué.
  static bool isSensitiveFile(String path) {
    final name = path.split(RegExp(r'[\\/]')).last.toLowerCase();
    if (name == 'key.properties' ||
        name == 'local.properties' ||
        name == 'credentials.json' ||
        name == 'service-account.json' ||
        name == '.npmrc' ||
        name == '.netrc' ||
        name == '.pypirc' ||
        name == 'id_rsa' ||
        name == 'id_ed25519' ||
        name.startsWith('.env')) {
      return true;
    }
    const extensions = [
      '.jks',
      '.keystore',
      '.p12',
      '.pfx',
      '.pem',
      '.key',
      '.p8',
      '.mobileprovision',
      '.cer',
      '.der',
    ];
    return extensions.any(name.endsWith);
  }
}
