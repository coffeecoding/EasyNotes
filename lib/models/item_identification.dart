// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ItemIdentification {
  final String? id;
  final String? parent_id;
  ItemIdentification({
    this.id,
    this.parent_id,
  });

  ItemIdentification copyWith({
    String? id,
    String? parent_id,
  }) {
    return ItemIdentification(
      id: id ?? this.id,
      parent_id: parent_id ?? this.parent_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'parent_id': parent_id,
    };
  }

  factory ItemIdentification.fromMap(Map<String, dynamic> map) {
    return ItemIdentification(
      id: map['id'] != null ? map['id'] as String : null,
      parent_id: map['parent_id'] != null ? map['parent_id'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemIdentification.fromJson(String source) =>
      ItemIdentification.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ItemIdentification(id: $id, parent_id: $parent_id)';

  @override
  bool operator ==(covariant ItemIdentification other) {
    if (identical(this, other)) return true;

    return other.id == id && other.parent_id == parent_id;
  }

  @override
  int get hashCode => id.hashCode ^ parent_id.hashCode;
}
