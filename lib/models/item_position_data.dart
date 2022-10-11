// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class ItemPositionData extends Equatable {
  final List<String> itemIds;
  final List<int> itemPositions;
  final int timestamp;
  const ItemPositionData({
    required this.itemIds,
    required this.itemPositions,
    required this.timestamp,
  });

  ItemPositionData copyWith({
    List<String>? itemIds,
    List<int>? itemPositions,
    int? timestamp,
  }) {
    return ItemPositionData(
      itemIds: itemIds ?? this.itemIds,
      itemPositions: itemPositions ?? this.itemPositions,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'itemIds': itemIds,
      'itemPositions': itemPositions,
      'timestamp': timestamp,
    };
  }

  factory ItemPositionData.fromMap(Map<String, dynamic> map) {
    return ItemPositionData(
      itemIds: List<String>.from(map['itemIds'] as List<String>),
      itemPositions: List<int>.from(map['itemPositions'] as List<int>),
      timestamp: map['timestamp'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemPositionData.fromJson(String source) =>
      ItemPositionData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ItemPositionData(itemIds: $itemIds, itemPositions: $itemPositions, timestamp: $timestamp)';

  @override
  bool operator ==(covariant ItemPositionData other) {
    if (identical(this, other)) return true;

    return listEquals(other.itemIds, itemIds) &&
        listEquals(other.itemPositions, itemPositions) &&
        other.timestamp == timestamp;
  }

  @override
  List<Object?> get props => [itemIds, itemPositions, timestamp];
}
