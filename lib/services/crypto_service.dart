import 'dart:convert';

import 'package:easynotes/config/locator.dart';
import 'package:easynotes/models/item.dart';
import 'package:easynotes/repositories/preference_repository.dart';
import 'package:easynotes/utils/crypto/crypto.dart';

class CryptoService {
  CryptoService() : prefsRepo = locator.get<PreferenceRepository>();

  late PreferenceRepository prefsRepo;

  Future<Item> encryptItem(Item item, [String? pubkey]) async {
    pubkey ??= await prefsRepo.pubkey;
    if (pubkey == null) {
      throw 'CryptopServices.encryptItem: pub key not found';
    }
    StatefulAES aes = await _ensureIVKeyIsSetAndCreateAES(item, pubkey);
    Item encryptedItem = Item.fromJson(item.toJson());
    encryptedItem = item.copyWith(
        title: aes.encryptToBase64(item.title),
        content: item.content.isEmpty
            ? item.content
            : aes.encryptToBase64(item.content),
        trashed: item.trashed);
    return encryptedItem;
  }

  Future<Item> decryptItem(Item item, [String? privKey]) async {
    privKey ??= await prefsRepo.privkey;
    if (privKey == null) {
      throw 'CryptopServices.decryptItem: priv key not found';
    }
    StatefulAES aes = _decodeIVKeyAndCreateAES(item.ivkey!, privKey);
    return item.copyWith(
        title: aes.decryptFromBase64(item.title),
        content: item.content.isEmpty
            ? item.content
            : aes.decryptFromBase64(item.content),
        trashed: item.trashed);
  }

  Future<List<Item>> encryptItems(Iterable<Item> items) async {
    String? privkey = await prefsRepo.privkey;
    if (privkey == null) {
      throw 'CryptopServices.encryptItems: pub key not found';
    }
    return Future.wait(items.map((i) => encryptItem(i, privkey)));
  }

  Future<List<Item>> decryptItems(Iterable<Item> items) async {
    String? privkey = await prefsRepo.privkey;
    if (privkey == null) {
      throw 'CryptopServices.decryptItems: private key not found';
    }
    return Future.wait(items.map((i) => decryptItem(i, privkey)));
  }

  Future<StatefulAES> _ensureIVKeyIsSetAndCreateAES(
      Item item, String rsaPubKeyXml) async {
    if (item.ivkey == null) {
      StatefulAES aes = StatefulAES();
      item.ivkey = _encodeIVKey(aes, rsaPubKeyXml);
      return aes;
    } else {
      String? privKeyXml = await prefsRepo.privkey;
      if (privKeyXml == null) {
        throw 'CryptopServices._ensureIVKeyIsSetAndCreateAES: private key not found';
      }
      return _decodeIVKeyAndCreateAES(item.ivkey!, privKeyXml);
    }
  }

  String _encodeIVKey(StatefulAES aes, String pubKeyXml) {
    List<int> keyCrypt = RSAHelper.rsaEncrypt(aes.key(), pubKeyXml);
    List<int> ivKey = aes.iv();
    ivKey.addAll(keyCrypt);
    return base64.encode(ivKey);
  }

  StatefulAES _decodeIVKeyAndCreateAES(String ivKey64, String privKeyXml) {
    List<int> ivKeyBytes = base64.decode(ivKey64);
    String iv64 = base64.encode(ivKeyBytes.sublist(0, 16));
    List<int> key =
        RSAHelper.rsaDecrypt(base64.encode(ivKeyBytes.sublist(16)), privKeyXml);
    String key64 = base64.encode(key);
    return StatefulAES.fromParams(key64, iv64);
  }
}
