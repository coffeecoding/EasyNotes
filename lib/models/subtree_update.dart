// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:easynotes/models/item_identification.dart';

class SubtreeUpdate {
  final String? new_parent_id;
  final bool did_trashed_state_change;
  final int timestamp;
  final int? new_trashed_value;
  final List<ItemIdentification> affected_items;
  SubtreeUpdate({
    this.new_parent_id,
    required this.did_trashed_state_change,
    required this.timestamp,
    this.new_trashed_value,
    required this.affected_items,
  });

  SubtreeUpdate copyWith({
    String? new_parent_id,
    bool? did_trashed_state_change,
    int? timestamp,
    int? new_trashed_value,
    List<ItemIdentification>? affected_items,
  }) {
    return SubtreeUpdate(
      new_parent_id: new_parent_id ?? this.new_parent_id,
      did_trashed_state_change:
          did_trashed_state_change ?? this.did_trashed_state_change,
      timestamp: timestamp ?? this.timestamp,
      new_trashed_value: new_trashed_value ?? this.new_trashed_value,
      affected_items: affected_items ?? this.affected_items,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'new_parent_id': new_parent_id,
      'did_trashed_state_change': did_trashed_state_change,
      'timestamp': timestamp,
      'new_trashed_value': new_trashed_value,
      'affected_items': affected_items.map((x) => x.toMap()).toList(),
    };
  }

  factory SubtreeUpdate.fromMap(Map<String, dynamic> map) {
    return SubtreeUpdate(
      new_parent_id:
          map['new_parent_id'] != null ? map['new_parent_id'] as String : null,
      did_trashed_state_change: map['did_trashed_state_change'] as bool,
      timestamp: map['timestamp'] as int,
      new_trashed_value: map['new_trashed_value'] != null
          ? map['new_trashed_value'] as int
          : null,
      affected_items: List<ItemIdentification>.from(
        (map['affected_items'] as List<int>).map<ItemIdentification>(
          (x) => ItemIdentification.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory SubtreeUpdate.fromJson(String source) =>
      SubtreeUpdate.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SubtreeUpdate(new_parent_id: $new_parent_id, did_trashed_state_change: $did_trashed_state_change, timestamp: $timestamp, new_trashed_value: $new_trashed_value, affected_items: $affected_items)';
  }

  @override
  bool operator ==(covariant SubtreeUpdate other) {
    if (identical(this, other)) return true;

    return other.new_parent_id == new_parent_id &&
        other.did_trashed_state_change == did_trashed_state_change &&
        other.timestamp == timestamp &&
        other.new_trashed_value == new_trashed_value &&
        listEquals(other.affected_items, affected_items);
  }

  @override
  int get hashCode {
    return new_parent_id.hashCode ^
        did_trashed_state_change.hashCode ^
        timestamp.hashCode ^
        new_trashed_value.hashCode ^
        affected_items.hashCode;
  }
}
