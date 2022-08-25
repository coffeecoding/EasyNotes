// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'item.dart';

class AuthResult extends Equatable {
  final bool success;
  final String error;
  final String token;
  final List<Item> items;
  const AuthResult({
    required this.success,
    required this.error,
    required this.token,
    required this.items,
  });

  AuthResult copyWith({
    bool? success,
    String? error,
    String? token,
    List<Item>? items,
  }) {
    return AuthResult(
      success: success ?? this.success,
      error: error ?? this.error,
      token: token ?? this.token,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'success': success,
      'error': error,
      'token': token,
      'items': items.map((x) => x.toMap()).toList(),
    };
  }

  factory AuthResult.fromMap(Map<String, dynamic> map) {
    return AuthResult(
      success: map['success'] as bool,
      error: map['error'] as String,
      token: map['token'] as String,
      items: List<Item>.from(
        (map['items'] as List<int>).map<Item>(
          (x) => Item.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthResult.fromJson(String source) =>
      AuthResult.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [success, error, token, items];
}
