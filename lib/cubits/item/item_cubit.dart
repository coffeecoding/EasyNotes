import 'package:bloc/bloc.dart';
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
        super(item.id.isEmpty
            ? const ItemState.newDraft()
            : ItemState.persisted(
                titleField: item.title, contentField: item.content)) {
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
  ItemStatus get status => state.status;

  // Local UI state
  bool expanded;
  String get titleField => state.titleField;
  String get contentField => state.contentField;

  Future<bool> save() async {
    String t = state.titleField;
    String c = state.contentField;
    try {
      // itemsCubit.emit(ItemsState.busy(prev: itemsCubit.state));
      //emit(ItemState.busy(titleField: t, contentField: c));
      Item updated = item.copyWith(title: t, content: c);
      await itemRepo.insertOrUpdateItem(updated);
      item = updated;
      emit(ItemState.persisted(
          titleField: item.title, contentField: item.content));
      itemsCubit.handleSelectedNoteChanged(this);
      return true;
    } catch (e) {
      print("error saving item: $e");
      emit(ItemState.error(
          titleField: t, contentField: c, errorMsg: 'Failed to save: $e'));
      return false;
    }
  }

  void saveLocalState(
      {ItemStatus? newStatus,
      required String titleField,
      required String contentField}) {
    if (newStatus != state.status) {
      if (newStatus == ItemStatus.draft) {
        emit(ItemState.draft(
            titleField: titleField, contentField: contentField));
      } else if (newStatus == ItemStatus.persisted) {
        emit(ItemState.persisted(
            titleField: item.title, contentField: item.content));
      }
      itemsCubit.handleSelectedNoteChanged(this);
    }
  }

  void resetState() {
    emit(ItemState.persisted(
        titleField: item.title, contentField: item.content));
    itemsCubit.handleSelectedNoteChanged(this);
  }

  void addChild(ItemCubit child) {
    // todo: resort according to preferences
    children.add(child);
  }

  void removeChild(ItemCubit child) {
    children = children.where((c) => c.id != child.id).toList();
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
