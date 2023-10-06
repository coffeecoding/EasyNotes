import 'package:easynotes/models/models.dart';

enum ItemUpdateAction { none, insert, update, updateHeaderOnly }

abstract class ItemRepository {
  Item getRootOf(Item item);
  Future<List<Item>> setItems(List<Item> items);
  List<Item> getItemAndChildren(String id);
  List<Item> getItems();
  Future<OPResult<List<Item>>> fetchItems();
  Future<OPResult<List<Item>>> fetchUntrashedItems();
  Future<OPResult<List<Item>>> fetchTrashedItems();
  Future<OPResult<List<Item>>> fetchRootItems();
  Future<OPResult<List<Item>>> fetchItemsByRootParentId(String? rootId);
  Future<OPResult<Item>> insertOrUpdateItem(Item item, ItemUpdateAction action);
  Future<OPResult<List<Item>>> insertOrUpdateItems(List<Item> items);
  Future<OPResult<Item>> updateItemHeader(ItemHeader header);
  Future<OPResult<Item>> updateItemParent(List<String> ids, String? parent_id,
      [bool untrash = false]);
  Future<OPResult<Item>> updateItemTrashed(List<String> ids, int? trashed);
  Future<OPResult<Item>> updateItemPinned(String id, int pin);
  Future<OPResult<Item>> updateItemGloballyPinned(String id, int pin);
  Future<OPResult<List<Item>>> updateItemPositions(List<String> itemIds);
  Future<OPResult<bool>> delete(String id);
  Future<OPResult<bool>> deleteItems(List<String> ids);

  Future<Item> createNewItem(
      {required String? parent_id, required String color, required int type});

  void reset();
}
