import 'package:easynotes/models/models.dart';

enum ItemUpdateAction { none, insert, update, updateHeaderOnly }

abstract class ItemRepository {
  Item getRootOf(Item item);
  Future<List<Item>> setItems(List<Item> items);
  List<Item> getItemAndChildren(String id);
  List<Item> getItems();

  Future<Item> createNewItem(
      {required String? parent_id, required String color, required int type});

  void reset();
}
