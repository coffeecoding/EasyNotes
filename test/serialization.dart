import 'dart:convert';

import 'package:easynotes/models/auth_result.dart';
import 'package:easynotes/models/item.dart';
import 'package:easynotes/config/sample_data.dart';

/// How to deserialize json list in 2022 !!!
void main() {
  final items = SampleData.sampleItems;

  dynamic serializedItems = jsonEncode(items);

  //print(serializedItems);

  final deser = List.from(jsonDecode(serializedItems))
      .map((i) => Item.fromJson(i))
      .toList();

  print(deser.length);
  print(deser[2]);

  print("Apply the same to an empty list");

  final empty = <Item>[];
  final emptySer = jsonEncode(empty);
  final de =
      List.from(jsonDecode(emptySer)).map((i) => Item.fromJson(i)).toList();

  print(de);

  // Now with AuthResult
  AuthResult ar =
      AuthResult(success: true, error: "", token: "asdftoken", items: items);

  final json = jsonEncode(ar);

  print(json);

  print("\nDecoding json again\n");

  final reAr = jsonDecode(json);

  print(reAr.toString());
}
