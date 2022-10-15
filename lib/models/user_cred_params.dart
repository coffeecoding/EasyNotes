// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:easynotes/utils/crypto/algorithm_identifier.dart';

class UserCredParams extends Equatable {
  final String pwsalt;
  final AlgorithmIdentifier algorithm_identifier;
  const UserCredParams({
    required this.pwsalt,
    required this.algorithm_identifier,
  });

  UserCredParams copyWith({
    String? pwsalt,
    AlgorithmIdentifier? algorithm_identifier,
  }) {
    return UserCredParams(
      pwsalt: pwsalt ?? this.pwsalt,
      algorithm_identifier: algorithm_identifier ?? this.algorithm_identifier,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pwsalt': pwsalt,
      'algorithm_identifier': algorithm_identifier.serialize(),
    };
  }

  factory UserCredParams.fromMap(Map<String, dynamic> map) {
    return UserCredParams(
      pwsalt: map['pwsalt'] as String,
      algorithm_identifier:
          AlgorithmIdentifier.deserialize(map['algorithm_identifier']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserCredParams.fromJson(String source) =>
      UserCredParams.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [pwsalt, algorithm_identifier];
}
