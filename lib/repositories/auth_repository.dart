// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:easynotes/config/locator.dart';
import 'package:easynotes/extensions/http_client_ext.dart';
import 'package:easynotes/models/models.dart';
import 'package:easynotes/repositories/preference_repository.dart';
import 'package:easynotes/utils/crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:pointycastle/asymmetric/api.dart';

import '../services/network_provider.dart';

class AuthRepository {
  AuthRepository()
      : netClient = locator.get<NetworkProvider>(),
        prefsRepo = locator.get<PreferenceRepository>();

  late NetworkProvider netClient;
  late PreferenceRepository prefsRepo;

  Future<bool> updateUser({String? newPassword, String? newEmail}) async {
    try {
      final user = await prefsRepo.loggedInUser;
      String newPwHash = user!.pwhash;
      String newPrivKeyCrypt = user.privkey_crypt;
      if (newPwHash == user.pwhash && newEmail == user.email) {
        // don't do anything, nothing changed
        return true;
      }
      if (newPassword != null) {
        newPwHash = await RFC2898Helper.computePasswordHash(
            newPassword,
            user.pwsalt,
            user.algorithm_identifier.iterations,
            user.algorithm_identifier.hashLen);
        final privkey = await prefsRepo.privkey;
        RSAPrivateKey pk = RSAHelper.parseRSAPrivateKeyFromXml(privkey!);
        List<int> privKeyBytes =
            utf8.encode(RSAHelper.xmlEncodeRSAPrivateKey(pk));
        newPrivKeyCrypt = await RFC2898Helper.encryptWithDerivedKey(
            newPassword, user.pwsalt, privKeyBytes);
      }
      User updated = user.copyWith(
          pwhash: newPwHash, privkey_crypt: newPrivKeyCrypt, email: newEmail);
      String updatedUser = updated.toJson();
      Response response = await netClient.put('/api/user/update', updatedUser);
      bool success = response.body.toUpperCase() == 'TRUE';
      if (success) {
        String pw = newPassword ?? (await prefsRepo.password)!;
        String privKey = (await prefsRepo.privkey)!;
        prefsRepo.setAuth(
            user: user,
            username: user.id,
            password: pw,
            pubkey: user.pubkey,
            privkey: privKey,
            signkey: '');
      }
      return success;
    } catch (e) {
      print('Error updating user $e');
      return false;
    }
  }

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

      // 5) save creds securely in secure storage
      String privKey = await RFC2898Helper.decryptWithDerivedKey(
          password, p.pwsalt, authData.user!.privkey_crypt);
      /*String signKey = await RFC2898Helper.decryptWithDerivedKey(
          password, p.pwsalt, authData.user!.signing_key_crypt);*/
      await prefsRepo.setAuth(
          user: authData.user!,
          username: username,
          password: password,
          privkey: privKey,
          pubkey: authData.user!.pubkey,
          signkey: '');

      // 6) pass the successfully retrieved item data to the caller
      return MapEntry('', authData.items);
    } catch (e) {
      print(e);
      return MapEntry('An unexpected error occurred: ${e}', []);
    }
  }

  Future<void> logout() async {
    await prefsRepo.clearAuth();
  }

  Future<Response> _getUserAuthParams(String username) async => username.isEmpty
      ? throw Exception('Username required')
      : await netClient.get('/api/user/$username/params');

  Future<bool> signup(User user) async {
    try {
      String userJson = user.toJson();
      Response re = await netClient.post('/api/user/register', userJson);
      if (!re.isSuccessStatusCode()) {
        print('Signup failed: ${re.reasonPhrase}');
        return false;
      }
      return true;
    } catch (e) {
      print('Error signing up: $e');
      return false;
    }
  }
}
