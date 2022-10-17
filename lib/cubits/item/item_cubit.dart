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
        titleField = item.title,
        titleExtentOffset = 0,
        titleBaseOffset = 0,
        contentField = item.content,
        contentExtentOffset = 0,
        contentBaseOffset = 0,
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
  ItemStatus get status => state.status;

  // Local UI state
  bool expanded;
  String titleField;
  int titleExtentOffset;
  int titleBaseOffset;
  String contentField;
  int contentExtentOffset;
  int contentBaseOffset;
  FocussedElement? focussedElement;

  Future<void> save({String? title, String? content}) async {
    try {
      emit(const ItemState.busy());
      Item updated = item.copyWith(title: title, content: content);
      await itemRepo.insertOrUpdateItem(updated);
      emit(const ItemState.persisted());
    } catch (e) {
      print("error saving item: $e");
      emit(ItemState.error(errorMsg: 'Failed to save: $e'));
    }
  }

  void saveLocalState(
      {ItemStatus? newStatus,
      String? title,
      String? content,
      int? titleBaseOffset = 0,
      int? titleExtentOffset = 0,
      int? contentBaseOffset = 0,
      int? contentExtentOffset = 0,
      FocussedElement? focussedElement}) {
    titleField = title ?? titleField;
    this.titleExtentOffset = titleExtentOffset ?? this.titleExtentOffset;
    this.titleBaseOffset = titleBaseOffset ?? this.titleBaseOffset;
    contentField = content ?? contentField;
    this.contentExtentOffset = contentExtentOffset ?? this.contentExtentOffset;
    this.contentBaseOffset = contentBaseOffset ?? this.contentBaseOffset;
    this.focussedElement = focussedElement ?? this.focussedElement;
    ItemStatus status = newStatus ?? state.status;
    if (newStatus != state.status) {
      if (newStatus == ItemStatus.draft) {
        emit(const ItemState.draft());
      } else if (newStatus == ItemStatus.persisted) {
        emit(const ItemState.persisted());
      }
      itemsCubit.emit(ItemsState.changed(
          prev: itemsCubit.state,
          selectedNote: itemsCubit.selectedNote,
          didChildExpansionToggle: itemsCubit.state.didChildExpansionToggle,
          differentialRebuildNoteToggle:
              !itemsCubit.state.differentialRebuildNoteToggle));
    }
  }

  void resetState() {
    titleField = item.title;
    titleExtentOffset = 0;
    titleBaseOffset = 0;
    contentField = item.content;
    contentExtentOffset = 0;
    contentBaseOffset = 0;
    itemsCubit.emit(ItemsState.changed(
        prev: itemsCubit.state,
        selectedNote: itemsCubit.selectedNote,
        didChildExpansionToggle: itemsCubit.state.didChildExpansionToggle,
        differentialRebuildNoteToggle:
            !itemsCubit.state.differentialRebuildNoteToggle));
    emit(const ItemState.persisted());
  }

  void addChild(ItemCubit child) {
    // todo: resort according to preferences
    children.add(child);
  }

  void removeChild(ItemCubit child) {
    children = children.where((c) => c.id != child.id).toList();
  }

  Future<void> changeParent(ItemCubit newParent) async {
    try {
      emit(const ItemState.busy());
      Item updated = item.copyWith(parent_id: newParent.id);
      await itemRepo.updateItemParent(updated.id, newParent.id);
      parent = newParent;
      parent!.removeChild(this);
      newParent.addChild(this);
      emit(const ItemState.persisted());
      // emit ItemsState state changed
    } catch (e) {
      print("error changing item parent: $e");
      emit(ItemState.error(errorMsg: 'Failed to change parent: $e'));
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
