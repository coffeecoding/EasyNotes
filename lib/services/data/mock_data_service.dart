import 'package:easynotes/models/item.dart';
import 'package:easynotes/models/item_header.dart';
import 'package:easynotes/models/opresult.dart';
import 'package:easynotes/models/subtree_update.dart';
import 'package:easynotes/repositories/abstract_item_repository.dart';
import 'package:easynotes/services/data/abstract_data_service.dart';

class MockDataService implements DataService {
  @override
  Future<OPResult<List<Item>>> getAllItems() {
    // TODO: implement getAllItems
    throw UnimplementedError();
  }

  @override
  Future<OPResult<List<Item>>> getItemSubtree(String? rootId) {
    // TODO: implement getItemSubtree
    throw UnimplementedError();
  }

  @override
  Future<OPResult<List<Item>>> getRootItems() {
    // TODO: implement getRootItems
    throw UnimplementedError();
  }

  @override
  Future<OPResult<int>> updateItemGloballyPinned(String id, int pin) {
    // TODO: implement updateItemGloballyPinned
    throw UnimplementedError();
  }

  @override
  Future<OPResult<Item>> updateItemHeader(ItemHeader header) {
    // TODO: implement updateItemHeader
    throw UnimplementedError();
  }

  @override
  Future<OPResult<SubtreeUpdate>> updateItemParent(
      String id, String? parent_id) {
    // TODO: implement updateItemParent
    throw UnimplementedError();
  }

  @override
  Future<OPResult<int>> updateItemPinned(String id, int pin) {
    // TODO: implement updateItemPinned
    throw UnimplementedError();
  }

  @override
  Future<OPResult<int>> updateItemPositions(List<String> ids) {
    // TODO: implement updateItemPositions
    throw UnimplementedError();
  }

  @override
  Future<OPResult<Item>> upsertItem(Item item, ItemUpdateAction action) {
    // TODO: implement upsertItem
    throw UnimplementedError();
  }

  @override
  Future<OPResult<List<Item>>> upsertItems(List<Item> items) {
    // TODO: implement upsertItems
    throw UnimplementedError();
  }

  @override
  Future<OPResult<int>> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }
}
