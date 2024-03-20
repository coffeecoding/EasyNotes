import 'package:easynotes/models/item.dart';
import 'package:easynotes/models/item_header.dart';
import 'package:easynotes/models/opresult.dart';
import 'package:easynotes/models/subtree_update.dart';
import 'package:easynotes/repositories/abstract_item_repository.dart';

abstract class DataService {
  Future<OPResult<List<Item>>> getAllItems();
  Future<OPResult<List<Item>>> getRootItems();
  Future<OPResult<List<Item>>> getItemSubtree(String? rootId);
  Future<OPResult<Item>> upsertItem(Item item, ItemUpdateAction action);
  Future<OPResult<List<Item>>> upsertItems(List<Item> items);
  Future<OPResult<Item>> updateItemHeader(ItemHeader header);
  Future<OPResult<SubtreeUpdate>> updateItemParent(
      String id, String? parent_id);
  Future<OPResult<int>> updateItemPinned(String id, int pin);
  Future<OPResult<int>> updateItemGloballyPinned(String id, int pin);
  Future<OPResult<int>> updateItemPositions(List<String> ids);
  Future<OPResult<int>> delete(String id);
}
