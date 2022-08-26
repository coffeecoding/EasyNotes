import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurePreferencesRepository {
  SecurePreferencesRepository() : _secureStorage = const FlutterSecureStorage();

  static const String _usernameKey = 'username';
  static const String _passwordKey = 'password';
  static const String _privkeyKey = 'privkey';
  static const String _signkeyKey = 'signkey';

  final FlutterSecureStorage _secureStorage;

  Future<bool> get loggedIn async => await username != null;
  Future<String?> get username async => _secureStorage.read(key: _usernameKey);
  Future<String?> get password async => _secureStorage.read(key: _passwordKey);
  Future<String?> get privkey async => _secureStorage.read(key: _privkeyKey);
  Future<String?> get signkey async => _secureStorage.read(key: _signkeyKey);

  Future<void> setAuth({
    required String username,
    required String password,
    required String privkey,
    required String signkey,
  }) async {
    const AndroidOptions androidOptions = AndroidOptions(resetOnError: true);
    const WindowsOptions windowsOptions = WindowsOptions();
    try {
      await _secureStorage.write(
        key: _usernameKey,
        value: username,
        aOptions: androidOptions,
        wOptions: windowsOptions,
      );
      await _secureStorage.write(
        key: _passwordKey,
        value: password,
        aOptions: androidOptions,
        wOptions: windowsOptions,
      );
      await _secureStorage.write(
        key: _privkeyKey,
        value: privkey,
        aOptions: androidOptions,
        wOptions: windowsOptions,
      );
      await _secureStorage.write(
        key: _signkeyKey,
        value: signkey,
        aOptions: androidOptions,
        wOptions: windowsOptions,
      );
    } catch (_) {
      try {
        await _secureStorage.deleteAll(
          aOptions: androidOptions,
        );
      } catch (_) {
        // Invoke logger here
      }
      rethrow;
    }
  }
}
