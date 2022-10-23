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
        super(item.id.isEmpty
            ? const ItemState.newDraft()
            : ItemState.persisted(
                colorSelection: item.color,
                titleField: item.title,
                contentField: item.content,
                modified: item.modified)) {
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
  String get colorSelection => state.colorSelection;

  ItemUpdateAction getWriteAction() {
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

  Future<bool> save() async {
    String t = state.titleField;
    String c = state.contentField;
    String clr = state.colorSelection;
    try {
      int ts = DateTime.now().toUtc().millisecondsSinceEpoch;
      ItemUpdateAction iua = getWriteAction();
      Item updated = item.copyWith(
          title: t,
          content: c,
          color: clr,
          created: iua == ItemUpdateAction.insert ? ts : item.created,
          modified: ts,
          modified_header: ts);
      item = await itemRepo.insertOrUpdateItem(updated, iua);
      emit(ItemState.persisted(
          colorSelection: clr,
          titleField: item.title,
          contentField: item.content,
          modified: ts));
      return true;
    } catch (e) {
      print("error saving item: $e");
      emit(ItemState.error(
          prev: state,
          titleField: t,
          contentField: c,
          errorMsg: 'Failed to save: $e'));
      return false;
    }
  }

  void saveLocalState(
      {ItemStatus? newStatus,
      required String titleField,
      required String contentField,
      String? color}) {
    if (newStatus != state.status) {
      if (newStatus == ItemStatus.draft) {
        emit(ItemState.draft(
            prev: state,
            colorSelection: color,
            titleField: titleField,
            contentField: contentField));
      } else if (newStatus == ItemStatus.persisted) {
        emit(ItemState.persisted(
            colorSelection: color ?? state.colorSelection,
            titleField: item.title,
            contentField: item.content,
            modified: item.modified));
      }
    }
  }

  void resetState() {
    emit(ItemState.persisted(
        colorSelection: item.color,
        titleField: item.title,
        contentField: item.content,
        modified: item.modified));
    itemsCubit.handleSelectedNoteChanged(this);
  }

  void addChild(ItemCubit child) {
    // todo: resort according to preferences
    children.add(child);
    // todo: consider if we need an event emission here
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
