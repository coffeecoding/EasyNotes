// ignore_for_file: non_constant_identifier_names

import 'package:easynotes/models/models.dart';
import 'package:easynotes/config/sample_data.dart';
import 'package:uuid/uuid.dart';

import 'item_repository.dart';

class MockItemRepo implements ItemRepository {
  Map<String, Item> items = {};

  @override
  String getColorOfRoot(Item item) {
    String color = item.color;
    Item? parent = items[item.parent_id];
    while (parent != null) {
      color = parent.color;
      parent = items[parent.parent_id];
    }
    return color;
  }

  @override
  List<Item> getItemAndChildren(String id) {
    Item? root = items[id];
    if (root == null) {
      return [];
    }
    Iterable<Item> children = items.values.where((i) => i.parent_id == id);
    return [root, ...children];
  }

  @override
  Future<Item> createNewItem(
      {required String? parent_id,
      required String color,
      required int type}) async {
    return Item.empty(
      id: const Uuid().v4(),
      color: color,
      parent_id: parent_id,
      receiver_id: 'a',
      type: type,
    );
  }

  @override
  Future<bool> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    items.removeWhere((key, value) => key == id);
    return true;
  }

  @override
  Future<bool> deleteItems(List<String> ids) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    items.removeWhere((key, value) => ids.any((i) => key == i));
    return true;
  }

  @override
  Future<List<Item>> fetchItems() async {
    await Future.delayed(const Duration(seconds: 1));
    SampleData.sampleItems.forEach((i) => items[i.id] = i);
    return items.values.toList();
  }

  @override
  Future<List<Item>> fetchRootItems() async {
    await Future.delayed(const Duration(seconds: 1));
    return items.values.where((i) => i.parent_id == null).toList();
  }

  @override
  Future<List<Item>> fetchUntrashedItems() async {
    // TODO: implement fetchTrashedItems
    throw UnimplementedError();
  }

  @override
  Future<List<Item>> fetchTrashedItems() async {
    // TODO: implement fetchTrashedItems
    throw UnimplementedError();
  }

  @override
  List<Item> getItems() {
    return items.values.toList();
  }

  @override
  Future<Item> insertOrUpdateItem(Item item, ItemUpdateAction action) async {
    await Future.delayed(const Duration(milliseconds: 500));
    items.update(item.id, (value) => item, ifAbsent: () => item);
    return item;
  }

  @override
  Future<List<Item>> insertOrUpdateItems(List<Item> items) async {
    for (var element in items) {
      insertOrUpdateItem(element, ItemUpdateAction.insert);
    }
    return this
        .items
        .values
        .where((i) => items.any((j) => j.id == i.id))
        .toList();
  }

  @override
  Future<List<Item>> setItems(List<Item> items) async {
    await Future.delayed(const Duration(milliseconds: 500));
    this.items.clear();
    for (var i in items) {
      this.items[i.id] = i;
    }
    return items;
  }

  @override
  Future<Item> updateItemGloballyPinned(String id, int pin) async {
    // TODO: implement updateItemGloballyPinned
    throw UnimplementedError();
  }

  @override
  Future<Item> updateItemHeader(ItemHeader header) async {
    // TODO: implement updateItemHeader
    throw UnimplementedError();
  }

  @override
  Future<Item> updateItemParent(List<String> ids, String? parent_id,
      [bool untrash = false]) async {
    String id = ids[0];
    await Future.delayed(const Duration(milliseconds: 200));
    int time = DateTime.now().toUtc().millisecondsSinceEpoch;
    items[id] = items[id]!.copyWith(
        parent_id: parent_id,
        trashed: untrash ? null : items[id]!.trashed,
        modified_header: time);
    if (untrash == true) {
      for (String idd in ids) {
        items[idd] = items[idd]!.copyWith(trashed: null, modified_header: time);
      }
    }
    return items[id]!;
  }

  @override
  Future<Item> updateItemPinned(String id, int pin) async {
    await Future.delayed(const Duration(milliseconds: 500));
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    items[id] = items[id]!.copyWith(
        pinned: pin != 0,
        trashed: items[id]!.trashed,
        modified_header: timestamp);
    return items[id]!;
  }

  @override
  Future<List<Item>> updateItemPositions(List<String> itemIds) async {
    int timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    for (int i = 0; i < itemIds.length; i++) {
      final id = itemIds[i];
      items[id] = items[id]!.copyWith(
          position: i, modified_header: timestamp, trashed: items[id]!.trashed);
    }
    List<Item> result =
        items.values.where((i) => itemIds.any((id) => id == i.id)).toList();
    return result;
  }

  @override
  Future<Item> updateItemTrashed(List<String> ids, int? trashed) async {
    String id = ids[0];
    await Future.delayed(const Duration(milliseconds: 500));
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    for (String i in ids) {
      items[i] =
          items[i]!.copyWith(trashed: trashed, modified_header: timestamp);
    }
    return items[id]!;
  }
}
