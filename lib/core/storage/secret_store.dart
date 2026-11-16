import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstraction du stockage de secrets, remplaçable dans les tests.
///
/// Les implémentations ne doivent jamais inclure une valeur secrète dans un
/// message d'erreur ou un journal.
abstract interface class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<bool> contains(String key);
}

/// Le trousseau du système est inaccessible (service Secret Service absent,
/// trousseau verrouillé, etc.).
class SecretStoreUnavailableException implements Exception {
  const SecretStoreUnavailableException(this.reason);

  /// Code d'erreur technique, sans aucune donnée secrète.
  final String reason;

  @override
  String toString() => 'SecretStoreUnavailableException($reason)';
}

/// Implémentation basée sur `flutter_secure_storage`.
/// Sous Linux, elle utilise libsecret (gnome-keyring, KWallet…).
class SystemSecretStore implements SecretStore {
  SystemSecretStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _guard(() => _storage.read(key: key));

  @override
  Future<void> write(String key, String value) =>
      _guard(() => _storage.write(key: key, value: value));

  @override
  Future<void> delete(String key) => _guard(() => _storage.delete(key: key));

  @override
  Future<bool> contains(String key) =>
      _guard(() => _storage.containsKey(key: key));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PlatformException catch (e) {
      // Seul le code est conservé : le message natif pourrait citer la valeur.
      throw SecretStoreUnavailableException(e.code);
    } on MissingPluginException {
      throw const SecretStoreUnavailableException('missing-plugin');
    }
  }
}
