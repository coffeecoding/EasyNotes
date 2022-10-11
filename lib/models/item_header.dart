// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'json_data.dart';

class ItemHeader extends Equatable with JsonData {
  final String id;
  String? parent_id;
  final String receiver_id;
  final String? sender_id;
  final bool pinned;
  final bool pinned_globally;
  final String symbol;
  final int item_type;
  final String color;
  final String options;
  String? ivkey;
  final String? signature;
  final int position;
  final int created;
  final int modified_header;
  final int modified;
  final int? trashed;

  ItemHeader({
    required this.id,
    this.parent_id,
    required this.receiver_id,
    this.sender_id,
    required this.pinned,
    required this.pinned_globally,
    required this.symbol,
    required this.item_type,
    required this.color,
    required this.options,
    this.ivkey,
    this.signature,
    required this.position,
    required this.created,
    required this.modified_header,
    required this.modified,
    this.trashed,
  });

  ItemHeader copyWith({
    String? id,
    String? parent_id,
    String? receiver_id,
    String? sender_id,
    bool? pinned,
    bool? pinned_globally,
    String? symbol,
    int? item_type,
    String? color,
    String? options,
    String? ivkey,
    String? signature,
    int? position,
    int? created,
    int? modified_header,
    int? modified,
    int? trashed,
  }) {
    return ItemHeader(
      id: id ?? this.id,
      parent_id: parent_id ?? this.parent_id,
      receiver_id: receiver_id ?? this.receiver_id,
      sender_id: sender_id ?? this.sender_id,
      pinned: pinned ?? this.pinned,
      pinned_globally: pinned_globally ?? this.pinned_globally,
      symbol: symbol ?? this.symbol,
      item_type: item_type ?? this.item_type,
      color: color ?? this.color,
      options: options ?? this.options,
      ivkey: ivkey ?? this.ivkey,
      signature: signature ?? this.signature,
      position: position ?? this.position,
      created: created ?? this.created,
      modified_header: modified_header ?? this.modified_header,
      modified: modified ?? this.modified,
      trashed: trashed ?? this.trashed,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'parent_id': parent_id,
      'receiver_id': receiver_id,
      'sender_id': sender_id,
      'pinned': pinned,
      'pinned_globally': pinned_globally,
      'symbol': symbol,
      'item_type': item_type,
      'color': color,
      'options': options,
      'ivkey': ivkey,
      'signature': signature,
      'position': position,
      'created': created,
      'modified_header': modified_header,
      'modified': modified,
      'trashed': trashed,
    };
  }

  factory ItemHeader.fromMap(Map<String, dynamic> map) {
    return ItemHeader(
      id: map['id'] as String,
      parent_id: map['parent_id'] != null ? map['parent_id'] as String : null,
      receiver_id: map['receiver_id'] as String,
      sender_id: map['sender_id'] != null ? map['sender_id'] as String : null,
      pinned: map['pinned'] as bool,
      pinned_globally: map['pinned_globally'] as bool,
      symbol: map['symbol'] as String,
      item_type: map['item_type'] as int,
      color: map['color'] as String,
      options: map['options'] as String,
      ivkey: map['ivkey'] != null ? map['ivkey'] as String : null,
      signature: map['signature'] != null ? map['signature'] as String : null,
      position: map['position'] as int,
      created: map['created'] as int,
      modified_header: map['modified_header'] as int,
      modified: map['modified'] as int,
      trashed: map['trashed'] != null ? map['trashed'] as int : null,
    );
  }

  @override
  String toJson() => json.encode(toMap());

  factory ItemHeader.fromJson(String source) =>
      ItemHeader.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      id,
      parent_id,
      receiver_id,
      sender_id,
      pinned,
      pinned_globally,
      symbol,
      item_type,
      color,
      options,
      ivkey,
      signature,
      position,
      created,
      modified_header,
      modified,
      trashed,
    ];
  }
}
