import 'package:bloc/bloc.dart';
import 'package:easynotes/config/constants.dart';
import 'package:easynotes/cubits/children_items/children_items_cubit.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:easynotes/cubits/trashed_items/trashed_items_cubit.dart';
import 'package:easynotes/models/item.dart';
import 'package:easynotes/repositories/item_repository.dart';
import 'package:equatable/equatable.dart';

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
      List<Item> updatedRootItems = await itemRepo.updateItemPositions(itemIds);
      updatedRootItems.sort(((a, b) => a.position.compareTo(b.position)));
      for (int i = 0; i < updatedRootItems.length; i++) {
        topicCubits[i].item = updatedRootItems[i];
      }
    } catch (e) {
      // todo: handle
    }
  }

  @override
  Future<void> fetchItems() async {
    try {
      emit(RootItemsState.busy(prev: state));
      final items = await itemRepo.fetchItems();
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
}
