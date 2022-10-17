import 'package:bloc/bloc.dart';
import 'package:easynotes/config/locator.dart';
import 'package:easynotes/cubits/items/items_cubit.dart';
import 'package:easynotes/models/item.dart';
import 'package:easynotes/repositories/item_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'item_state.dart';

class ItemCubit extends Cubit<ItemState> {
  ItemCubit(
      {required this.item,
      required this.itemsCubit,
      required ItemCubit? parent,
      required List<Item> items,
      this.expanded = false})
      : itemRepo = locator.get<ItemRepository>(),
        titleField = item.title,
        contentField = item.content,
        contentExtentOffset = 0,
        contentBaseOffset = 0,
        super(ItemState.initial(
            parent: parent, title: item.title, content: item.content)) {
    initChildren(items);
  }

  void initChildren(List<Item> childrenItems) {
    children = createChildrenCubitsForParent(itemsCubit, this, childrenItems);
  }

  final ItemRepository itemRepo;
  final ItemsCubit itemsCubit;
  late List<ItemCubit> children;
  Item item;

  String get id => item.id;
  String get color => item.color;
  String get symbol => item.symbol;
  String get title => item.title;
  int get item_type => item.item_type;
  ItemCubit? get parent => state.parent;
  bool get isTopic => item.isTopic;

  // UI state that only needs to trigger a rebuild on ItemsCubit rebuilding
  bool expanded;
  String titleField;
  String contentField;
  int contentExtentOffset;
  int contentBaseOffset;
  FocusNode? focusNode;

  Future<void> save({String? title, String? content}) async {
    try {
      emit(const ItemState.saving());
      Item updated = item.copyWith(title: title, content: content);
      await itemRepo.insertOrUpdateItem(updated);
      emit(ItemState.success(prev: state));
    } catch (e) {
      print("error saving item: $e");
      emit(ItemState.error(prev: state, errorMsg: 'Failed to save: $e'));
    }
  }

  void saveLocalState(
      {String? title,
      String? content,
      int contentBaseOffset = 0,
      int contentExtentOffset = 0,
      FocusNode? focusNode}) {
    // instead of "success" we should add another state like "draft"
    // IMPORTANT TODO !! ^
    titleField = title ?? titleField;
    contentField = content ?? contentField;
    this.contentExtentOffset = contentExtentOffset;
    this.contentBaseOffset = contentBaseOffset;
    this.focusNode = focusNode;
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
      emit(const ItemState.saving());
      Item updated = item.copyWith(parent_id: newParent.id);
      await itemRepo.updateItemParent(updated.id, newParent.id);
      parent!.removeChild(this);
      newParent.addChild(this);
      emit(ItemState.success(prev: state, parent: newParent));
    } catch (e) {
      print("error changing item parent: $e");
      emit(ItemState.error(
          prev: state, errorMsg: 'Failed to change parent: $e'));
    }
  }

  List<ItemCubit> getAncestors() {
    final result = <ItemCubit>[];
    ItemCubit? cursor = state.parent;
    while (cursor != null) {
      result.add(cursor.parent!);
      cursor = cursor.parent;
    }
    return result;
  }

  int getAncestorCount() {
    int result = 0;
    ItemCubit? cursor = state.parent;
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
