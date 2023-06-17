// // manages the complete tree of items (both trashed and non trashed)
// import 'package:easynotes/cubits/item_vm/item_vm.dart';
// import 'package:easynotes/models/item.dart';
// import 'package:easynotes/repositories/item_repository.dart';

/*
class ItemsStateManager {
  ItemsStateManager({required this.itemRepo})
      : root = ItemVM(
            item:
                Item.empty(id: null, parent_id: null, type: 0, receiver_id: ''),
            parent: null,
            items: []),
        searchRoot = ItemVM(
            item:
                Item.empty(id: null, parent_id: null, type: 0, receiver_id: ''),
            parent: null,
            items: []),
        trashRoot = ItemVM(
            item:
                Item.empty(id: null, parent_id: null, type: 0, receiver_id: ''),
            parent: null,
            items: []);

  final ItemRepository itemRepo;

  // absolute tree root: this one contains the root non-trashed items
  final ItemVM root;
  // absolute search result root: this one contains the root non-trashed items
  final ItemVM searchRoot;
  // absolute trash root: this one contains the root trashed items or leaves
  final ItemVM trashRoot;

  List<ItemVM> initRootItems() {
    final items = itemRepo.getItems().where((i) => i.trashed == null).toList();
    final rootItems = ItemVM.createChildrenCubitsForParent(root, items);
    return rootItems;
  }

  void initTrashedItems() {
    final items = itemRepo.getItems();
    // go through all leaves in trashed items (item w no children)
    final fullRoots =
        ItemVM.createChildrenCubitsForParent(trashRoot, items.toList());
    final subtrees = trashRoot
        .getDescendantsRecursive()
        .where((i) =>
            i.parent == trashRoot ||
            (i.parent!.trashed == null && i.trashed != null))
        .toList();
    trashRoot.children.clear();
    trashRoot.children = subtrees;
  }
}
*/