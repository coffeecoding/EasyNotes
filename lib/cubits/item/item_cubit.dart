import 'package:bloc/bloc.dart';
import 'package:easynotes/config/locator.dart';
import 'package:easynotes/cubits/items/items_cubit.dart';
import 'package:easynotes/models/item.dart';
import 'package:easynotes/repositories/item_repository.dart';
import 'package:equatable/equatable.dart';

part 'item_state.dart';

class ItemCubit extends Cubit<ItemState> {
  ItemCubit(
      {required this.item,
      required this.itemsCubit,
      required ItemCubit? parent,
      required List<Item> items})
      : itemRepo = locator.get<ItemRepository>(),
        super(ItemState.initial(parent: parent)) {
    // Problem: We can't pass "this" to "createChildrenCubitsForParent" in
    // the initializer list or super-constructor, so we have to initialize
    // this cubit using the empty dummy state and then after initialization
    // reinitialize it's state with the children
    initChildren(items);
  }

  void initChildren(List<Item> childrenItems) {
    emit(ItemState.populated(
        parent: parent,
        title: item.title,
        content: item.content,
        children:
            createChildrenCubitsForParent(itemsCubit, this, childrenItems)));
  }

  final ItemRepository itemRepo;
  final ItemsCubit itemsCubit;
  Item item;

  String get id => item.id;
  String get color => item.color;
  String get symbol => item.symbol;
  String get title => item.title;
  ItemCubit? get parent => state.parent;
  List<ItemCubit> get children => state.children;
  bool get isTopic => item.isTopic;

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

  void addChild(ItemCubit child) {
    emit(ItemState.populated(
        parent: parent,
        title: item.title,
        content: item.content,
        children: [...children, child]));
  }

  void removeChild(ItemCubit child) {
    emit(ItemState.populated(
        parent: parent,
        title: item.title,
        content: item.content,
        children: children.where((c) => c.id != child.id).toList()));
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

  List<ItemCubit> getParents() {
    final result = <ItemCubit>[];
    ItemCubit? cursor = state.parent;
    while (cursor != null) {
      result.add(state.parent!);
      cursor = state.parent;
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
