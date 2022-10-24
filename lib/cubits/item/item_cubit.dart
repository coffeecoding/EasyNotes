import 'package:bloc/bloc.dart';
import 'package:easynotes/config/constants.dart';
import 'package:easynotes/config/locator.dart';
import 'package:easynotes/cubits/items/items_cubit.dart';
import 'package:easynotes/models/item.dart';
import 'package:easynotes/repositories/item_repository.dart';
import 'package:equatable/equatable.dart';

part 'item_state.dart';

enum FocussedElement { title, content }

class ItemCubit extends Cubit<ItemState> {
  ItemCubit(
      {required this.item,
      required this.itemsCubit,
      required this.parent,
      required List<Item> items,
      this.expanded = false})
      : itemRepo = locator.get<ItemRepository>(),
        titleField = item.title,
        contentField = item.content,
        colorSelection = item.color,
        error = '',
        super(item.id.isEmpty
            ? const ItemState.newDraft()
            : const ItemState.persisted()) {
    initChildren(items);
  }

  void initChildren(List<Item> childrenItems) {
    children = createChildrenCubitsForParent(itemsCubit, this, childrenItems);
  }

  final ItemRepository itemRepo;
  final ItemsCubit itemsCubit;
  late List<ItemCubit> children;
  ItemCubit? parent;
  Item item;

  String get id => item.id;
  String get color => item.color;
  String get symbol => item.symbol;
  String get title => item.title;
  String get content => item.content;
  int get item_type => item.item_type;
  bool get isTopic => item.isTopic;
  bool get pinned => item.pinned;
  ItemStatus get status => state.status;

  // Local UI state
  bool expanded;
  String? titleField;
  String? contentField;
  String? colorSelection;
  String error;

  ItemUpdateAction getWriteAction(
      String titleField, String contentField, String colorSelection) {
    if (status == ItemStatus.newDraft) {
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
      emit(const ItemState.persisted());
      return true;
    } catch (e) {
      print("error saving item: $e");
      error = 'failed to save item: $e';
      emit(const ItemState.error());
      return false;
    }
  }

  Future<void> togglePinned() async {
    if (status == ItemStatus.newDraft) return;
    try {
      // technically gotta emit busy state, but we're not listening to it
      bool newValue = !pinned;
      final updated = await itemRepo.updateItemPinned(id, newValue ? 1 : 0);
      item = updated;
      emit(const ItemState.persisted());
      final bla = children;
      parent!.sortChildren();
      itemsCubit.handleItemsChanged();
    } catch (e) {
      print("error saving item: $e");
      error = 'failed to save item: $e';
      emit(const ItemState.error());
    }
  }

  void sortChildren() {
    if (children.isEmpty) {
      return;
    } else {
      children.sort((a, b) => a.isTopic && !b.isTopic
          ? -1
          : !a.pinned && b.pinned
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
      {ItemStatus? newStatus,
      String? titleField,
      String? contentField,
      String? colorSelection}) {
    this.titleField = titleField ?? this.titleField;
    this.contentField = contentField ?? this.contentField;
    this.colorSelection = colorSelection ?? item.color;
    if (newStatus == ItemStatus.draft) {
      emit(const ItemState.draft());
    } else if (newStatus == ItemStatus.newDraft) {
      emit(const ItemState.newDraft());
    }
  }

  void resetState() {
    if (status == ItemStatus.draft) {
      titleField = title;
      contentField = content;
      colorSelection = color;
      emit(const ItemState.persisted());
      if (isTopic) {
        itemsCubit.handleItemsChanged();
      } else {
        itemsCubit.handleSelectedNoteChanged(this);
      }
    } else if (status == ItemStatus.newDraft) {
      if (parent == null) {
        itemsCubit.removeTopic(this);
      } else {
        parent?.removeChild(this);
      }
      if (isTopic) {
        itemsCubit.handleItemsChanged();
      } else {
        itemsCubit.handleSelectedNoteChanged(null);
      }
    }
  }

  void addChild(ItemCubit child) {
    // todo: resort according to preferences
    children.add(child);
    // todo: consider if we need an event emission here
  }

  void insertChildAtTop(ItemCubit child) {
    // todo: resort according to preferences
    children.insert(0, child);
    // todo: consider if we need an event emission here
  }

  void removeChild(ItemCubit child) {
    children.remove(child);
    itemsCubit.handleItemsChanged();
  }

  void discardSubtopicChanges(ItemCubit child) {
    if (child.status == ItemStatus.newDraft) {
      removeChild(child);
    } else {
      child.resetState();
    }
  }

  Future<void> changeParent(ItemCubit? newParent) async {
    try {
      itemsCubit.emit(ItemsState.busy(prev: itemsCubit.state));
      Item updated = item.copyWith(parent_id: newParent?.id);
      await itemRepo.updateItemParent(updated.id, newParent?.id);
      if (parent != null) {
        parent!.removeChild(this);
      } else {
        itemsCubit.topicCubits.remove(this);
        // if the new item is a new topic, select that one,
        // else if it's null (i.e. a child topic became a root topic),
        // then don't reselect the topic
        if (newParent != null) {
          itemsCubit.selectTopicDirectly(newParent);
        }
      }
      parent = newParent;
      if (newParent == null) {
        itemsCubit.addTopic(this);
      } else {
        newParent.addChild(this);
      }
      itemsCubit.handleItemsChanged();
      itemsCubit.handleRootItemsChanged();
    } catch (e) {
      print("error changing item parent: $e");
      // Reconsider: trigger error state in the item itself instead?
      itemsCubit
          .emit(ItemsState.error(errorMsg: 'Failed to change parent: $e'));
    }
  }

  List<ItemCubit> getAncestors() {
    final result = <ItemCubit>[];
    ItemCubit? cursor = parent;
    while (cursor != null) {
      result.add(cursor.parent!);
      cursor = cursor.parent;
    }
    return result;
  }

  int getAncestorCount() {
    int result = 0;
    ItemCubit? cursor = parent;
    while (cursor != null) {
      result += 1;
      cursor = cursor.parent;
    }
    return result;
  }

  static List<ItemCubit> createChildrenCubitsForParent(
      ItemsCubit itemsCubit, ItemCubit? parent, List<Item> items) {
    return items
        .where((i) => i.parent_id == parent?.id)
        .map((i) => ItemCubit(
            itemsCubit: itemsCubit, parent: parent, item: i, items: items))
        .toList();
  }
}
