// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:math';

import 'package:easynotes/utils/crypto/crypto.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final bool email_verified;
  final String display_name;
  final int created;
  final String? avatar;
  final String pwsalt;
  final String pwhash;
  final String pubkey;
  final String privkey_crypt;
  final String verifying_key;
  final String signing_key_crypt;
  final String algorithm_identifier;
  const User({
    required this.id,
    required this.email,
    required this.email_verified,
    required this.display_name,
    required this.created,
    this.avatar,
    required this.pwsalt,
    required this.pwhash,
    required this.pubkey,
    required this.privkey_crypt,
    required this.verifying_key,
    required this.signing_key_crypt,
    required this.algorithm_identifier,
  });

  @override
  // TODO: implement props
  List<Object?> get props {
    return [
      id,
      email,
      email_verified,
      display_name,
      created,
      avatar,
      pwsalt,
      pwhash,
      pubkey,
      privkey_crypt,
      verifying_key,
      signing_key_crypt,
      algorithm_identifier,
    ];
  }

  User copyWith({
    String? id,
    String? email,
    bool? email_verified,
    String? display_name,
    int? created,
    String? avatar,
    String? pwsalt,
    String? pwhash,
    String? pubkey,
    String? privkey_crypt,
    String? verifying_key,
    String? signing_key_crypt,
    String? algorithm_identifier,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      email_verified: email_verified ?? this.email_verified,
      display_name: display_name ?? this.display_name,
      created: created ?? this.created,
      avatar: avatar ?? this.avatar,
      pwsalt: pwsalt ?? this.pwsalt,
      pwhash: pwhash ?? this.pwhash,
      pubkey: pubkey ?? this.pubkey,
      privkey_crypt: privkey_crypt ?? this.privkey_crypt,
      verifying_key: verifying_key ?? this.verifying_key,
      signing_key_crypt: signing_key_crypt ?? this.signing_key_crypt,
      algorithm_identifier: algorithm_identifier ?? this.algorithm_identifier,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'email_verified': email_verified,
      'display_name': display_name,
      'created': created,
      'avatar': avatar,
      'pwsalt': pwsalt,
      'pwhash': pwhash,
      'pubkey': pubkey,
      'privkey_crypt': privkey_crypt,
      'verifying_key': verifying_key,
      'signing_key_crypt': signing_key_crypt,
      'algorithm_identifier': algorithm_identifier,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      email_verified: map['email_verified'] as bool,
      display_name: map['display_name'] as String,
      created: map['created'] as int,
      avatar: map['avatar'] != null ? map['avatar'] as String : null,
      pwsalt: map['pwsalt'] as String,
      pwhash: map['pwhash'] as String,
      pubkey: map['pubkey'] as String,
      privkey_crypt: map['privkey_crypt'] as String,
      verifying_key: map['verifying_key'] as String,
      signing_key_crypt: map['signing_key_crypt'] as String,
      algorithm_identifier: map['algorithm_identifier'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  static const empty = User(
      id: '',
      email: '',
      email_verified: false,
      display_name: '',
      created: 0,
      pwsalt: '',
      pwhash: '',
      pubkey: '',
      privkey_crypt: '',
      verifying_key: '',
      signing_key_crypt: '',
      algorithm_identifier: '');

  static Future<User> create(String id, String email, String password) async {
    Random rnd = Random.secure();
    List<int> salt = List<int>.generate(
        AlgorithmIdentifier.defSaltLen, (i) => rnd.nextInt(256));

    String saltBase64 = base64.encode(salt);

    String passwordHash = await RFC2898Helper.computePasswordHash(
        password,
        saltBase64,
        AlgorithmIdentifier.defIterations,
        AlgorithmIdentifier.defHashLen);

    final rsaKeyPair = RSAHelper.createRSAKeyPair();
    List<int> privKeyBytes =
        utf8.encode(RSAHelper.xmlEncodeRSAPrivateKey(rsaKeyPair.privateKey));
    final String privKeyCrypt = await RFC2898Helper.encryptWithDerivedKey(
        password, saltBase64, privKeyBytes);
    final String pubKey = RSAHelper.xmlEncodeRSAPublicKey(rsaKeyPair.publicKey);

    final signingKeyPair = RSAHelper.createRSAKeyPair();
    List<int> signingKeyBytes = utf8
        .encode(RSAHelper.xmlEncodeRSAPrivateKey(signingKeyPair.privateKey));
    final String signingKeyCrypt = await RFC2898Helper.encryptWithDerivedKey(
        password, saltBase64, signingKeyBytes);
    final String verifyingKey =
        RSAHelper.xmlEncodeRSAPublicKey(signingKeyPair.publicKey);

    return User(
        id: id,
        email: email,
        email_verified: false,
        display_name: id,
        created: DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
        pwsalt: saltBase64,
        pwhash: passwordHash,
        pubkey: pubKey,
        privkey_crypt: privKeyCrypt,
        verifying_key: verifyingKey,
        signing_key_crypt: signingKeyCrypt,
        algorithm_identifier: AlgorithmIdentifier.getDefault().toJson());
  }
}
