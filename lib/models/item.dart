// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:easynotes/models/item_header.dart';
import 'package:equatable/equatable.dart';

import 'json_data.dart';

class Item extends Equatable with JsonData {
  final String id;
  String? parent_id;
  final String receiver_id;
  final String? sender_id;
  final String title;
  final String content;
  final bool pinned;
  final bool pinned_globally;
  final String symbol;
  final int item_type;
  final String color;
  final String options;
  String? ivkey;
  final String? signature;
  int position;
  final int created;
  final int modified_header;
  final int modified;
  final int? trashed;
  Item({
    required this.id,
    required this.parent_id,
    required this.receiver_id,
    this.sender_id,
    required this.title,
    required this.content,
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

  Item copyWith({
    String? id,
    String? parent_id,
    String? receiver_id,
    String? sender_id,
    String? title,
    String? content,
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
    return Item(
      id: id ?? this.id,
      parent_id: parent_id ?? this.parent_id,
      receiver_id: receiver_id ?? this.receiver_id,
      sender_id: sender_id ?? this.sender_id,
      title: title ?? this.title,
      content: content ?? this.content,
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

  Item copyWithHeader(ItemHeader header) {
    return Item(
        id: header.id,
        parent_id: header.parent_id,
        receiver_id: header.receiver_id,
        sender_id: header.sender_id,
        title: title,
        content: content,
        pinned: header.pinned,
        pinned_globally: header.pinned_globally,
        symbol: header.symbol,
        item_type: header.item_type,
        color: header.color,
        options: header.options,
        ivkey: header.ivkey,
        signature: header.signature,
        position: header.position,
        created: header.created,
        modified_header: header.modified_header,
        modified: header.modified,
        trashed: header.trashed);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'parent_id': parent_id,
      'receiver_id': receiver_id,
      'sender_id': sender_id,
      'title': title,
      'content': content,
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

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as String,
      parent_id: map['parent_id'] as String?,
      receiver_id: map['receiver_id'] as String,
      sender_id: map['sender_id'] != null ? map['sender_id'] as String : null,
      title: map['title'] as String,
      content: map['content'] as String,
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

  factory Item.fromJson(String source) =>
      Item.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  bool get isTopic => item_type == 0;

  ItemHeader getHeader() => ItemHeader(
      id: id,
      parent_id: parent_id,
      receiver_id: receiver_id,
      sender_id: sender_id,
      pinned: pinned,
      pinned_globally: pinned_globally,
      symbol: symbol,
      item_type: item_type,
      color: color,
      options: options,
      ivkey: ivkey,
      signature: signature,
      position: position,
      created: created,
      modified_header: modified_header,
      modified: modified,
      trashed: trashed);

  @override
  List<Object?> get props {
    return [
      id,
      parent_id,
      receiver_id,
      sender_id,
      title,
      content,
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
