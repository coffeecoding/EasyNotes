// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class MyObj {
  final String id;
  final String title;
  MyObj({
    required this.id,
    required this.title,
  });

  MyObj copyWith({
    String? id,
    String? title,
  }) {
    return MyObj(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
    };
  }

  factory MyObj.fromMap(Map<String, dynamic> map) {
    return MyObj(
      id: map['id'] as String,
      title: map['title'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory MyObj.fromJson(String source) =>
      MyObj.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'MyObj(id: $id, title: $title)';

  @override
  bool operator ==(covariant MyObj other) {
    if (identical(this, other)) return true;

    return other.id == id && other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}

void main() {
  List<MyObj> objects = [
    MyObj(id: '1', title: '00011'),
    MyObj(id: '2', title: 'YSxAG'),
    MyObj(id: '3', title: '80085'),
    MyObj(id: '4', title: 'T1'),
  ];

  print(objects);
  print('');

  print('Changing a single object in the middle ...');

  MyObj updatedObj = MyObj(id: '4', title: '<3');

  int i = objects.indexWhere((element) => element.id == '4');

  objects[i] = updatedObj;

  print('');
  print(objects);
}
