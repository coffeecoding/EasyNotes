// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class UserCredParams extends Equatable {
  final String pwhash;
  final String algorithm_identifier;
  const UserCredParams({
    required this.pwhash,
    required this.algorithm_identifier,
  });

  UserCredParams copyWith({
    String? pwhash,
    String? algorithm_identifier,
  }) {
    return UserCredParams(
      pwhash: pwhash ?? this.pwhash,
      algorithm_identifier: algorithm_identifier ?? this.algorithm_identifier,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pwhash': pwhash,
      'algorithm_identifier': algorithm_identifier,
    };
  }

  factory UserCredParams.fromMap(Map<String, dynamic> map) {
    return UserCredParams(
      pwhash: map['pwhash'] as String,
      algorithm_identifier: map['algorithm_identifier'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserCredParams.fromJson(String source) =>
      UserCredParams.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [pwhash, algorithm_identifier];
}
