// ignore_for_file: non_constant_identifier_names, avoid_print

import 'package:easynotes/config/locator.dart';
import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/models/item.dart';
import 'package:easynotes/repositories/item_repository.dart';

enum FocussedElement { title, content }

// Todo: remove "busy" state; it is not needed at all.
// Todo: get rid of the dependency on parentListCubit:
//    - all invocations of parentListCubit should be done outside (e.g.)
//      in the UI code
//    - this class should only be concerned with mutating it's *own* state,
//      not the state of it's parenting list.
enum ItemVMStatus { persisted, newDraft, draft, busy, error }

enum ItemLevel { root, childOfRoot, grandChild }

abstract class TreeNode {
  abstract ItemVM item;
  abstract ItemVM parent;
  abstract List<ItemVM> children;
  abstract ItemLevel get;
}

class ItemVM {
  ItemVM(
      {required this.item,
      this.status = ItemVMStatus.newDraft,
      required this.parent,
      required List<Item> items,
      this.expanded = false})
      : itemRepo = locator.get<ItemRepository>(),
        titleField = item.title,
        contentField = item.content,
        colorSelection = item.color,
        error = '',
        children = [] {
    initChildren(items);
  }

  void initChildren(List<Item> childrenItems) {
    if (item.isTopic) {
      children = ItemVM.createChildrenCubitsForParent(this, childrenItems);
    }
  }

  Item item;
  final ItemRepository itemRepo;
  List<ItemVM> children;
  ItemVM? parent;

  String get id => item.id;
  String get color => item.color;
  String get symbol => item.symbol;
  String get title => item.title;
  String get content => item.content;
  int get item_type => item.item_type;
  bool get isTopic => item.isTopic;
  bool get pinned => item.pinned;
  int? get trashed => item.trashed;

  ItemLevel get level => parent == null
      ? ItemLevel.root
      : parent != null && parent!.parent == null
          ? ItemLevel.childOfRoot
          : ItemLevel.grandChild;

  bool get isPersisted => id.isNotEmpty;

  // Local UI state
  ItemVMStatus status;
  bool expanded;
  String? titleField;
  String? contentField;
  String? colorSelection;
  FocussedElement? focussedElement;
  String error;

  ItemUpdateAction getWriteAction(
      String titleField, String contentField, String colorSelection) {
    if (status == ItemVMStatus.newDraft) {
      return ItemUpdateAction.insert;
    } else if (titleField == title &&
        contentField == content &&
        colorSelection == color) {
      // todo: compare all other header fields as well (options ...)
      return ItemUpdateAction.none;
    } else if (titleField == title && contentField == content) {
      return ItemUpdateAction.updateHeaderOnly;
    }
    return ItemUpdateAction.update;
  }

  Future<bool> save({
    String? titleField,
    String? contentField,
    String? colorSelection,
  }) async {
    try {
      int ts = DateTime.now().toUtc().millisecondsSinceEpoch;
      ItemUpdateAction iua = getWriteAction(titleField ?? title,
          contentField ?? content, colorSelection ?? color);
      Item updated = item.copyWith(
          title: titleField ?? title,
          content: contentField ?? content,
          color: colorSelection ?? color,
          created: iua == ItemUpdateAction.insert ? ts : item.created,
          modified: ts,
          modified_header: ts,
          trashed: item.trashed);
      item = await itemRepo.insertOrUpdateItem(updated, iua);
      status = ItemVMStatus.persisted;
      return true;
    } catch (e) {
      print("error saving item: $e");
      error = 'failed to save item: $e';
      status = ItemVMStatus.error;
      return false;
    }
  }

  Future<void> togglePinned() async {
    if (status == ItemVMStatus.newDraft) return;
    try {
      bool newValue = !pinned;
      final updated = await itemRepo.updateItemPinned(id, newValue ? 1 : 0);
      item = updated;
      status = ItemVMStatus.persisted;
      parent!.sortChildren();
    } catch (e) {
      print("error saving item: $e");
      error = 'failed to save item: $e';
    }
  }

  Future<void> restoreDescendantsFromTrash() async {
    restoreFromTrash(null);
    for (ItemVM c in children) {
      await c.restoreDescendantsFromTrash();
    }
  }

  /// Restores item from trash and updates its parent if updateParent is true;
  /// updateParent parameter is needed becausee newParent being null could
  /// either mean a) don't update parent or b) update parent to null.
  Future<void> restoreFromTrash(ItemVM? newParent,
      [bool updateParent = false]) async {
    try {
      List<String> ids =
          getDescendantsRecursive(true).map((i) => i.id).toList();
      if (updateParent) {
        item = await itemRepo.updateItemParent(ids, newParent?.id, true);
        await restoreDescendantsFromTrash();
        parent = newParent;
      }
      item = await itemRepo.updateItemTrashed(ids, null);
    } catch (e) {
      print("error restoring item from trash: $e");
      error = 'failed to restore item from item: $e';
    }
  }

  Future<void> trash() async {
    if (status == ItemVMStatus.newDraft) return;
    try {
      int time = DateTime.now().toUtc().millisecondsSinceEpoch;
      List<String> ids =
          getDescendantsRecursive(true).map((i) => i.id).toList();
      await itemRepo.updateItemTrashed(ids, time);
      reloadFromRepo();
      parent?.removeChild(this);
    } catch (e) {
      print("error trashing item: $e");
      error = 'failed to trash it item: $e';
    }
  }

  void sortChildren() {
    if (children.isEmpty) {
      return;
    } else {
      children.sort((a, b) => a.isTopic && !b.isTopic
          ? -1
          : !a.isTopic && b.isTopic
              ? 1
              : 0);
      children.sort((a, b) => a.pinned && !b.pinned
          ? -1
          : !a.pinned && b.pinned
              ? 1
              : 0);
    }
  }

  List<ItemVM> getDescendantsRecursive([bool includeRoot = false]) {
    if (isTopic) {
      final descendants = children
          .map((e) => e.getDescendantsRecursive(true))
          .expand((i) => i)
          .toList();
      return includeRoot ? [this, ...descendants] : descendants;
    } else {
      return [this];
    }
  }

  void reloadFromRepo() {
    List<Item> items = itemRepo.getItemAndChildren(id);
    item = items[0];
    items.removeAt(0);
    children = ItemVM.createChildrenCubitsForParent(this, items);
  }

  List<ItemVM> search(String term) {
    if (isTopic) {
      return children.map((c) => c.search(term)).expand((l) => l).toList();
    } else if (_matchesSearchTerm(term)) {
      return [this];
    } else {
      return [];
    }
  }

  bool _matchesSearchTerm(String term) {
    String upperTerm = term.toUpperCase();
    return status != ItemVMStatus.newDraft &&
        (title.toUpperCase().contains(upperTerm) ||
            content.toUpperCase().contains(upperTerm));
  }

  void saveLocalState(
      {ItemVMStatus? newStatus,
      String? titleField,
      String? contentField,
      String? colorSelection,
      FocussedElement? focussedElement}) {
    this.titleField = titleField ?? this.titleField;
    this.contentField = contentField ?? this.contentField;
    this.colorSelection = colorSelection ?? item.color;
    this.focussedElement = focussedElement ?? this.focussedElement;
    status = newStatus ?? status;
  }

  void resetState() {
    if (status == ItemVMStatus.draft) {
      titleField = title;
      contentField = content;
      colorSelection = color;
      status = ItemVMStatus.persisted;
    } else if (status == ItemVMStatus.newDraft) {
      parent?.removeChild(this);
    }
  }

  void addChild(ItemVM child) {
    children.add(child);
    sortChildren();
    // todo: consider if we need an event emission here
  }

  void insertChildAtTop(ItemVM child) {
    // todo: resort according to preferences
    children.insert(0, child);
    // todo: consider if we need an event emission here
  }

  void removeChild(ItemVM child) {
    children.remove(child);
  }

  void discardSubtopicChanges(ItemVM child) {
    if (child.status == ItemVMStatus.newDraft) {
      removeChild(child);
    } else {
      child.resetState();
      status = ItemVMStatus.persisted;
    }
  }

  Future<void> delete() async {
    try {
      await itemRepo.delete(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changeParent(
      {ItemVM? newParent,
      required RootItemsCubit ric,
      required ListWithSelectionCubit cic}) async {
    try {
      // This logic was carefully created according the documentation
      // in parent_changing.txt
      bool affectsRic = newParent == null || level == ItemLevel.root;
      if (affectsRic) {
        ric.handleItemsChanging();
      }
      cic.handleItemsChanging(silent: affectsRic);

      Item updated =
          item.copyWith(parent_id: newParent?.id, trashed: item.trashed);
      await itemRepo.updateItemParent([updated.id], newParent?.id);

      parent?.removeChild(this);
      newParent?.addChild(this);

      if (level == ItemLevel.root && newParent != null) {
        ric.removeItem(this);
        ric.handleItemsChanged();
      }
      if (newParent != null && newParent == ric.selectedItem) {
        if (cic is ChildrenItemsCubit) {
          cic.handleRootItemSelectionChanged(newParent);
        }
      } else {
        if (level == ItemLevel.childOfRoot) {
          if (newParent == null) {
            ric.addItem(this);
            ric.handleItemsChanged();
          }
          cic.removeItem(this);
        } else if (level == ItemLevel.grandChild && newParent == null) {
          ric.addItem(this);
          ric.handleItemsChanged();
        }
        cic.handleItemsChanged();
      }
      ric.handleItemsChanged();
      parent = newParent;
    } catch (e) {
      print("error changing item parent: $e");
      ric.handleError(e);
      rethrow;
    }
  }

  ItemVM? getRootAncestor() {
    final ancestors = getAncestors();
    return ancestors.isEmpty ? null : ancestors.last;
  }

  List<ItemVM> getAncestors() {
    final result = <ItemVM>[];
    ItemVM? cursor = parent;
    while (cursor != null && cursor.isPersisted) {
      result.add(cursor);
      cursor = cursor.parent;
    }
    return result;
  }

  int getTrashedAncestorCount() {
    int result = 0;
    ItemVM? cursor = parent;
    while (cursor != null && cursor.trashed != null && cursor.isPersisted) {
      result += 1;
      cursor = cursor.parent;
    }
    return result;
  }

  int getAncestorCount() {
    int result = 0;
    ItemVM? cursor = parent;
    while (cursor != null) {
      result += 1;
      cursor = cursor.parent;
    }
    return result;
  }

  // Finds the parent of an item in a list of (sub)trees. Example:
  // item (parent_id: '12')
  // list [(id: '1', children('10', '12', '20')), ('id: '5', children: [])]
  // -> returns subtree with root id 1's second child item
  ItemVM? findItemParentInTrees(ItemVM item) {
    if (id != null && id == item.parent?.id) {
      return this;
    }
    List<ItemVM?> p =
        children.map((c) => c.findItemParentInTrees(item)).toList();
    if (p.any((element) => element != null)) {
      return p.firstWhere((element) => element != null);
    } else {
      return null;
    }
  }

  static List<ItemVM> createChildrenCubitsForParent(
      ItemVM? parent, List<Item> items) {
    return items
        .where((i) => i.parent_id == parent?.id)
        .map((i) => ItemVM(
            parent: parent,
            status: ItemVMStatus.persisted,
            item: i,
            items: items))
        .toList();
  }
}
