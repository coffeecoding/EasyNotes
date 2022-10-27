// ignore_for_file: non_constant_identifier_names, avoid_print

import 'package:easynotes/config/locator.dart';
import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/cubits/root_items/root_items_cubit.dart';
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
        error = '' {
    initChildren(items);
  }

  void initChildren(List<Item> childrenItems) {
    if (item.isTopic) {
      children = ItemVM.createChildrenCubitsForParent(this, childrenItems);
    }
  }

  Item item;
  final ItemRepository itemRepo;
  late List<ItemVM> children;
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

  // Local UI state
  ItemVMStatus status;
  bool expanded;
  String? titleField;
  String? contentField;
  String? colorSelection;
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
          modified_header: ts);
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
      parent!.sortChildren();
    } catch (e) {
      print("error saving item: $e");
      error = 'failed to save item: $e';
    }
  }

  /// Restores item from trash and updates its parent if updateParent is true;
  /// updateParent parameter is needed becausee newParent being null could
  /// either mean a) don't update parent or b) update parent to null.
  Future<void> restoreFromTrash(ItemVM? newParent,
      [bool updateParent = false]) async {
    try {
      if (updateParent) {
        item = await itemRepo.updateItemParent(id, newParent?.id, true);
      }
      item = await itemRepo.updateItemTrashed(id, null);
    } catch (e) {
      print("error restoring item from trash: $e");
      error = 'failed to restore item from item: $e';
    }
  }

  Future<void> trash() async {
    if (status == ItemVMStatus.newDraft) return;
    try {
      int time = DateTime.now().toUtc().millisecondsSinceEpoch;
      Item updated = await itemRepo.updateItemTrashed(id, time);
      item = updated;
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

  List<ItemVM> search(String term, [List<ItemVM> acc = const []]) {
    if (isTopic) {
      return children.map((c) => c.search(term, [])).expand((l) => l).toList();
    } else if (_matchesSearchTerm(term)) {
      return [...acc, this];
    } else {
      return acc;
    }
  }

  bool _matchesSearchTerm(String term) {
    String upperTerm = term.toUpperCase();
    return title.toUpperCase().contains(upperTerm) ||
        content.toUpperCase().contains(upperTerm);
  }

  void saveLocalState(
      {ItemVMStatus? newStatus,
      String? titleField,
      String? contentField,
      String? colorSelection}) {
    this.titleField = titleField ?? this.titleField;
    this.contentField = contentField ?? this.contentField;
    this.colorSelection = colorSelection ?? item.color;
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
      required ChildrenItemsCubit cic}) async {
    try {
      // This logic was carefully created according the documentation
      // in parent_changing.txt
      bool affectsRic = newParent == null || level == ItemLevel.root;
      if (affectsRic) {
        ric.handleItemsChanging();
      }
      cic.handleItemsChanging(silent: affectsRic);

      Item updated = item.copyWith(parent_id: newParent?.id);
      await itemRepo.updateItemParent(updated.id, newParent?.id);

      parent?.removeChild(this);
      newParent?.addChild(this);

      if (level == ItemLevel.root) {
        ric.removeItem(this);
        ric.handleItemsChanged();
      }
      if (newParent != null && newParent == ric.selectedItem) {
        cic.handleRootItemSelectionChanged(newParent);
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
      // special case (1st in the text doc)
      if (level == ItemLevel.root &&
          newParent != null &&
          newParent.level == ItemLevel.root) {
        ric.handleItemsChanged();
      }
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
    while (cursor != null) {
      result.add(cursor);
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
