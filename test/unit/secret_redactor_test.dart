import 'package:flutter_test/flutter_test.dart';
import 'package:launchpilot/core/security/secret_redactor.dart';

/// Toutes les valeurs ci-dessous sont fictives.
void main() {
  const mask = SecretRedactor.mask;

  group('SecretRedactor.redact', () {
    final cases = <String, (String input, String leaked, SecretKind kind)>{
      'clé Anthropic': (
        'clé = sk-ant-api03-AbCdEfGhIjKlMnOpQrStUv',
        'sk-ant-api03-AbCdEfGhIjKlMnOpQrStUv',
        SecretKind.apiKey,
      ),
      'clé OpenAI': (
        'export OPENAI=sk-proj-1234567890abcdefXYZ',
        'sk-proj-1234567890abcdefXYZ',
        SecretKind.apiKey,
      ),
      'clé Google': (
        'apiKey: "AIzaSyA1234567890abcdefghijklmnopqrstu"',
        'AIzaSyA1234567890abcdefghijklmnopqrstu',
        SecretKind.apiKey,
      ),
      'clé AWS': (
        'aws AKIAABCDEFGHIJKLMNOP ici',
        'AKIAABCDEFGHIJKLMNOP',
        SecretKind.apiKey,
      ),
      'jeton GitHub': (
        'token ghp_abcdefghijklmnopqrstuvwxyz0123456789',
        'ghp_abcdefghijklmnopqrstuvwxyz0123456789',
        SecretKind.token,
      ),
      'JWT': (
        'Cookie: eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0In0.c2lnbmF0dXJlLXRlc3Q',
        'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0In0.c2lnbmF0dXJlLXRlc3Q',
        SecretKind.jwt,
      ),
      'en-tête Bearer': (
        'Authorization: Bearer abcdef1234567890ghijkl',
        'abcdef1234567890ghijkl',
        SecretKind.token,
      ),
      'mot de passe de keystore': (
        'storePassword=MonSuperMotDePasse!',
        'MonSuperMotDePasse!',
        SecretKind.password,
      ),
      'variable secrète': (
        'STRIPE_SECRET_KEY="rk_live_51Habcdefgh"',
        'rk_live_51Habcdefgh',
        SecretKind.envSecret,
      ),
      'chaîne de connexion': (
        'DATABASE_URL=postgres://admin:hunter2@db.local:5432/app',
        'hunter2',
        SecretKind.connectionString,
      ),
    };

    cases.forEach((name, c) {
      test(name, () {
        final (input, leaked, kind) = c;
        final r = SecretRedactor.redact(input);
        expect(r.text, isNot(contains(leaked)));
        expect(r.text, contains(mask));
        expect(r.counts.keys, contains(kind));
      });
    });

    test('clé privée PEM', () {
      const pem =
          '-----BEGIN OPENSSH PRIVATE KEY-----\nb3BlbnNzaC1rZXktdjEAAAA\n'
          '-----END OPENSSH PRIVATE KEY-----';
      final r = SecretRedactor.redact('avant\n$pem\naprès');
      expect(r.text, 'avant\n$mask\naprès');
      expect(r.counts[SecretKind.privateKey], 1);
    });

    test('garde le nom de la variable, masque seulement la valeur', () {
      final r = SecretRedactor.redact('keyPassword=abc12345');
      expect(r.text, 'keyPassword=$mask');
    });

    test('laisse intact un texte sans secret', () {
      const text =
          'version: 1.3.0+14\nflutter build appbundle --release\n'
          'Le mot « password » seul ne suffit pas.';
      final r = SecretRedactor.redact(text);
      expect(r.text, text);
      expect(r.total, 0);
    });

    test('est idempotent', () {
      final once = SecretRedactor.redact('token=abcdef123456').text;
      final twice = SecretRedactor.redact(once);
      expect(twice.text, once);
      expect(twice.total, 0);
    });

    test('redactKnown masque aussi une valeur non reconnue par les motifs', () {
      expect(
        SecretRedactor.redactKnown('erreur pour cle-maison-42', [
          'cle-maison-42',
        ]),
        'erreur pour $mask',
      );
    });
  });

  test('fichiers sensibles exclus', () {
    for (final path in [
      'android/key.properties',
      'android/app/upload-keystore.jks',
      'release.keystore',
      '.env',
      '.env.production',
      'certs/server.pem',
      'ios/profile.mobileprovision',
      r'C:\projet\signing.p12',
    ]) {
      expect(SecretRedactor.isSensitiveFile(path), isTrue, reason: path);
    }
    for (final path in ['pubspec.yaml', 'lib/main.dart', 'README.md']) {
      expect(SecretRedactor.isSensitiveFile(path), isFalse, reason: path);
    }
  });
}
