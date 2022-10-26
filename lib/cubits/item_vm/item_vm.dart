// ignore_for_file: non_constant_identifier_names, avoid_print

import 'package:easynotes/config/locator.dart';
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

  Future<void> changeParent(ItemVM? newParent) async {
    try {
      Item updated = item.copyWith(parent_id: newParent?.id);
      await itemRepo.updateItemParent(updated.id, newParent?.id);
      if (parent != null) {
        parent!.removeChild(this);
      }
      parent = newParent;
      if (newParent != null) {
        newParent.addChild(this);
      }
    } catch (e) {
      print("error changing item parent: $e");
      rethrow;
    }
  }

  List<ItemVM> getAncestors() {
    final result = <ItemVM>[];
    ItemVM? cursor = parent;
    while (cursor != null) {
      result.add(cursor.parent!);
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
