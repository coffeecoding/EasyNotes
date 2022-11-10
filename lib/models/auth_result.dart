// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:easynotes/models/user.dart';

import 'item.dart';

// Obsolete class
// The respective fields "token", "user" and "items" can be directly
// json-decoded from the json-body of the http response.

/*
class AuthResult extends Equatable {
  final bool success;
  final String error;
  final String token;
  final User? user;
  final List<Item> items;
  const AuthResult({
    required this.success,
    required this.error,
    required this.token,
    this.user,
    required this.items,
  });

  AuthResult copyWith({
    bool? success,
    String? error,
    String? token,
    User? user,
    List<Item>? items,
  }) {
    return AuthResult(
      success: success ?? this.success,
      error: error ?? this.error,
      token: token ?? this.token,
      user: user ?? this.user,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'success': success,
      'error': error,
      'token': token,
      'user': user?.toMap(),
      'items': items.map((x) => x.toMap()).toList(),
    };
  }

  factory AuthResult.fromMap(Map<String, dynamic> map) {
    return AuthResult(
      success: map['success'] as bool,
      error: map['error'] as String,
      token: map['token'] as String,
      user: map['user'] != null
          ? User.fromMap(map['user'] as Map<String, dynamic>)
          : null,
      items: map['items'] ?? map['items'] as List<Item>,
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthResult.fromJson(String source) =>
      AuthResult.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      success,
      error,
      token,
      user,
      items,
    ];
  }
}
*/