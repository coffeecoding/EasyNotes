import 'dart:async';
import 'dart:convert';

import 'package:easynotes/config/locator.dart';
import 'package:easynotes/extensions/http_client_ext.dart';
import 'package:easynotes/models/auth_result.dart';
import 'package:easynotes/models/models.dart';
import 'package:easynotes/repositories/preference_repository.dart';
import 'package:easynotes/utils/crypto/crypto.dart';
import 'package:http/http.dart';

import '../config/sample_data.dart';
import '../services/network_provider.dart';

class AuthRepository {
  AuthRepository()
      : netClient = locator.get<NetworkProvider>(),
        prefsRepo = locator.get<PreferenceRepository>();

  late NetworkProvider netClient;
  late PreferenceRepository prefsRepo;

  /// Empty string indicates success, non-empty String is error message.
  Future<MapEntry<String, List<Item>>> login(
      {required String username, required String password}) async {
    try {
      // 1) Get auth parameters and data
      final authParams = await _getUserAuthParams(username);
      if (!authParams.isSuccessStatusCode()) {
        return const MapEntry(
            'Something went wrong. Please try again later.', []);
      }
      final p = UserCredParams.fromJson(authParams.body);

      // 2) Compute password hash
      final pwhash = await RFC2898Helper.computePasswordHash(password, p.pwsalt,
          p.algorithm_identifier.iterations, p.algorithm_identifier.hashLen);

      // 3) Authenticate with api
      Map<String, dynamic> authSubmission = {
        'EmailOrUsername': username,
        'PasswordHash': pwhash,
      };
      final authResult =
          await netClient.post('/api/token', jsonEncode(authSubmission));

      // weird dart thing: it can't implicitly cast List<dynamic> as List<Item>
      // so we have to do this silly cast dance ...
      final jsonMap = jsonDecode(authResult.body) as Map<String, dynamic>;
      var itemList = jsonMap['items'] as List;
      jsonMap['items'] = itemList.cast<Item>().toList();
      final authData = AuthResult.fromMap(jsonMap);

      // 4) save token in http client
      netClient.setAuthHeader('Bearer ${authData.token}');
      print("Saved auth token:");
      print(authData.token);

      // 5) save creds securely in secure storage
      String privKey = await RFC2898Helper.decryptWithDerivedKey(
          password, p.pwsalt, authData.user!.privkey_crypt);
      String signKey = await RFC2898Helper.decryptWithDerivedKey(
          password, p.pwsalt, authData.user!.signing_key_crypt);
      await prefsRepo.setAuth(
          user: authData.user!,
          username: username,
          password: password,
          privkey: privKey,
          pubkey: authData.user!.pubkey,
          signkey: signKey);

      // 6) pass the successfully retrieved item data to the caller
      return MapEntry('', authData.items!);
    } catch (e) {
      print(e);
      return MapEntry('An unexpected error occurred: ${e}', []);
    }
  }

  logout() {
    // do logout logic
    // consider catching exceptions outside instead of here
  }

  Future<Response> _getUserAuthParams(String username) async => username.isEmpty
      ? throw Exception('Username required')
      : await netClient.get('/api/user/$username/params');
}
