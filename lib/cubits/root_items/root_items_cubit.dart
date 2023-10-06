import 'package:bloc/bloc.dart';
import 'package:easynotes/config/constants.dart';
import 'package:easynotes/cubits/children_items/children_items_cubit.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:easynotes/cubits/trashed_items/trashed_items_cubit.dart';
import 'package:easynotes/models/models.dart';
import 'package:easynotes/repositories/abstract_item_repository.dart';
import 'package:equatable/equatable.dart';

import 'package:easynotes/utils/list_extensions.dart';

part 'root_items_state.dart';

abstract class ListWithSelectionCubit {
  void addItem(ItemVM item);
  void insertItem(ItemVM item);
  void removeItem(ItemVM item);
  void handleItemsChanging({bool silent = false});
  void handleItemsChanged();
  void handleSelectionChanged(ItemVM? selected,
      [ChildListVisibility childListVisibility = ChildListVisibility.children]);
  void handleError(Object e);
  Future<void> fetchItems();
}

class RootItemsCubit extends Cubit<RootItemsState> with ListWithSelectionCubit {
  RootItemsCubit(
      {required this.itemRepo,
      required this.childrenItemsCubit,
      required this.trashedItemsCubit})
      : super(const RootItemsState.initial());

  final ItemRepository itemRepo;

  final ChildrenItemsCubit childrenItemsCubit;
  final TrashedItemsCubit trashedItemsCubit;

  List<ItemVM> get topicCubits => state.topicCubits;
  ItemVM? get selectedItem => state.selectedItem;

  @override
  void handleSelectionChanged(ItemVM? selected,
          [ChildListVisibility childListVisibility =
              ChildListVisibility.children]) =>
      emit(RootItemsState.ready(
          prev: state,
          selectedItem: selected,
          childListVisibility: childListVisibility));

  @override
  void addItem(ItemVM item) {
    // todo : apply preferred sorting
    topicCubits.add(item);
  }

  @override
  void removeItem(ItemVM item) {
    topicCubits.remove(item);
  }

  @override
  void insertItem(ItemVM item, [int index = 0]) {
    topicCubits.insert(index, item);
  }

  Future<ItemVM> createRootItem(int type) async {
    Item newItem = await itemRepo.createNewItem(
        parent_id: null, color: defaultItemColor, type: type);
    ItemVM newCubit =
        ItemVM(item: newItem, items: [], parent: null, expanded: false);
    return newCubit;
  }

  @override
  void handleItemsChanging({bool silent = false}) {
    if (silent) {
      emit(RootItemsState.busySilent(prev: state));
    } else {
      emit(RootItemsState.busy(prev: state));
    }
  }

  @override
  void handleItemsChanged() {
    emit(RootItemsState.ready(prev: state, selectedItem: selectedItem));
  }

  @override
  void handleError(Object e) {
    emit(RootItemsState.error(
        prev: state, errorMsg: 'Failed to retrieve data: $e'));
  }

  Future<void> updateRootItemPositions() async {
    try {
      List<String> itemIds = topicCubits.map((i) => i.id).toList();
      OPResult<List<Item>> result = await itemRepo.updateItemPositions(itemIds);
      if (result.hasData) {
        final updatedRootItems = result.data!;
        updatedRootItems.sort(((a, b) => a.position.compareTo(b.position)));
        for (int i = 0; i < updatedRootItems.length; i++) {
          topicCubits[i].item = updatedRootItems[i];
        }
      } else {
        print(result.msg);
        // todo: handle (not too critical, it's just sorting)
      }
    } catch (e) {
      // todo: handle (not too critical, it's just sorting)
    }
  }

  void getItemsFromRepo() {
    try {
      emit(RootItemsState.busy(prev: state));
      final items = itemRepo.getItems();
      final nonTrashedItems = items.where((i) => i.trashed == null).toList();
      final topicCubits =
          ItemVM.createChildrenCubitsForParent(null, nonTrashedItems);
      emit(RootItemsState.ready(prev: state, topicCubits: topicCubits));
    } catch (e) {
      print("error in items_cubit fetchTopics: $e");
      emit(RootItemsState.error(
          prev: state, errorMsg: 'Failed to retrieve data: $e'));
    }
  }

  Future<void> refetchSelectedRootItemSubtree() async {
    try {
      if (selectedItem == null) return;
      emit(RootItemsState.busy(prev: state));
      OPResult<List<Item>> re =
          await itemRepo.fetchItemsByRootParentId(selectedItem!.id);
      if (re.hasData) {
        final items = re.data!;
        Item root = items.removeAt(0);
        emit(RootItemsState.ready(
            prev: state,
            selectedItem: ItemVM(item: root, items: items, parent: null)));
      } else {
        print(re.msg);
        emit(RootItemsState.error(prev: state, errorMsg: re.friendlyMsg!));
      }
    } catch (e) {
      print("error fetching root item and children: $e");
      emit(RootItemsState.error(
          prev: state, errorMsg: 'Failed to retrieve rootitem & children: $e'));
    }
  }

  Future<void> fetchRootItems() async {
    try {
      if (selectedItem == null) return;
      emit(RootItemsState.busy(prev: state));
      OPResult<List<Item>> re = await itemRepo.fetchRootItems();
      if (re.hasData) {
        final roots = re.data!;
        for (int i = 0; i < topicCubits.length; i++) {
          Item? existingRoot =
              roots.singleOrNull((r) => r.id == topicCubits[i].id);
          if (existingRoot != null) {
            topicCubits[i].item = existingRoot;
          } else {
            addItem(ItemVM(item: roots[i], items: [], parent: null));
          }
        }
        emit(RootItemsState.ready(prev: state, topicCubits: topicCubits));
      } else {
        print(re.msg);
        emit(RootItemsState.error(prev: state, errorMsg: re.friendlyMsg!));
      }
    } catch (e) {
      print("error fetching root items: $e");
      emit(RootItemsState.error(
          prev: state, errorMsg: 'Failed to retrieve rootitems: $e'));
    }
  }

  @override
  Future<void> fetchItems() async {
    try {
      emit(RootItemsState.busy(prev: state));
      final re = await itemRepo.fetchItems();
      if (re.hasData) {
        final nonTrashedItems =
            re.data!.where((i) => i.trashed == null).toList();
        final topicCubits =
            ItemVM.createChildrenCubitsForParent(null, nonTrashedItems);
        emit(RootItemsState.ready(prev: state, topicCubits: topicCubits));
      } else {
        print(re.msg!);
        emit(RootItemsState.error(prev: state, errorMsg: re.friendlyMsg!));
      }
    } catch (e) {
      print("error in items_cubit fetchTopics: $e");
      emit(RootItemsState.error(
          prev: state, errorMsg: 'Failed to retrieve data: $e'));
    }
  }
}
