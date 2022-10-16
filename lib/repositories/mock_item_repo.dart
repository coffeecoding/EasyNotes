import 'package:easynotes/models/models.dart';
import 'package:easynotes/config/sample_data.dart';

import 'item_repository.dart';

class MockItemRepo implements ItemRepository {
  List<Item> items = <Item>[];
  List<Item> trashedItems = <Item>[];

  @override
  Future<bool> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    items.removeWhere((element) => element.id == id);
    return true;
  }

  @override
  Future<bool> deleteItems(List<String> ids) async {
    // TODO: implement deleteItems
    throw UnimplementedError();
  }

  @override
  Future<List<Item>> fetchItems() async {
    await Future.delayed(const Duration(seconds: 2));
    items = SampleData.sampleItems;
    return items;
  }

  @override
  Future<List<Item>> fetchRootItems() async {
    await Future.delayed(const Duration(seconds: 1));
    return items.where((element) => element.parent_id == null).toList();
  }

  @override
  Future<List<Item>> fetchTrashedItems() async {
    // TODO: implement fetchTrashedItems
    throw UnimplementedError();
  }

  @override
  List<Item> getItems() {
    return items;
  }

  @override
  List<Item> getRootItems() {
    return items.where((i) => i.parent_id == null).toList();
  }

  @override
  List<Item> getTrashedItems() {
    // TODO: implement getTrashedItems
    throw UnimplementedError();
  }

  @override
  Future<Item> insertOrUpdateItem(Item item) async {
    await Future.delayed(const Duration(milliseconds: 500));
    items.add(item);
    return item;
  }

  @override
  Future<List<Item>> insertOrUpdateItems(List<Item> items) async {
    // TODO: implement insertOrUpdateItems
    throw UnimplementedError();
  }

  @override
  Future<List<Item>> setItems(List<Item> items) async {
    await Future.delayed(const Duration(milliseconds: 500));
    this.items = items;
    return items;
  }

  @override
  Future<bool> updateItemGloballyPinned(String id, int pin) async {
    // TODO: implement updateItemGloballyPinned
    throw UnimplementedError();
  }

  @override
  Future<bool> updateItemHeader(ItemHeader header) async {
    // TODO: implement updateItemHeader
    throw UnimplementedError();
  }

  @override
  Future<bool> updateItemParent(String id, String parent_id) async {
    // TODO: implement updateItemParent
    throw UnimplementedError();
  }

  @override
  Future<bool> updateItemPinned(String id, int pin) async {
    await Future.delayed(const Duration(milliseconds: 500));
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int i = items.indexWhere((i) => i.id == id);
    items[i] = items[i].copyWith(pinned: pin != 0, modified_header: timestamp);
    return true;
  }

  @override
  Future<List<Item>> updateItemPositions(ItemPositionData ipd) async {
    // TODO: implement updateItemPositions
    throw UnimplementedError();
  }

  @override
  Future<bool> updateItemTrashed(String id, int trashed) async {
    // TODO: implement updateItemTrashed
    throw UnimplementedError();
  }
}
