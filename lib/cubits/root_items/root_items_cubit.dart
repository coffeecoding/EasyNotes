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
  void handleSelectionChanged(ItemVM? selected, [bool selectTrash = false]);
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

  List<ItemVM> get topicCubits =>
      state.topicCubits.where((t) => t.trashed == null).toList();
  ItemVM? get selectedItem => state.selectedItem;

  @override
  void handleSelectionChanged(ItemVM? selected, [bool selectTrash = false]) =>
      emit(RootItemsState.ready(
          prev: state, selectedItem: selected, isTrashSelected: selectTrash));

  @override
  void addItem(ItemVM item) {
    // todo : apply preferred sorting
    topicCubits.add(item);
    handleItemsChanged();
  }

  @override
  void removeItem(ItemVM item) {
    topicCubits.remove(item);
    handleItemsChanged();
  }

  @override
  void insertItem(ItemVM item) {
    topicCubits.insert(0, item);
    handleItemsChanged();
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

  @override
  Future<void> fetchItems() async {
    try {
      emit(RootItemsState.busy(prev: state));
      final items = await itemRepo.fetchItems();
      final nonTrashedItems = items.where((i) => i.trashed == null).toList();
      final topicCubits =
          ItemVM.createChildrenCubitsForParent(null, nonTrashedItems);

      // trashed items
      final trashedItems = items.where((i) => i.trashed != null).toList();
      trashedItemsCubit.handleItemsChanging();
      final topLevelTrashedItems = trashedItems
          .where((i) =>
              i.parent_id == null ||
              !trashedItems.any((p) => p.id == i.parent_id))
          .toList();
      final trashedItemVMs = topLevelTrashedItems
          .map((i) => ItemVM(
              item: i,
              items: trashedItems,
              parent: null,
              status: ItemVMStatus.persisted))
          .toList();
      trashedItemsCubit.handleItemsChanged(items: trashedItemVMs);

      emit(RootItemsState.ready(prev: state, topicCubits: topicCubits));
    } catch (e) {
      print("error in items_cubit fetchTopics: $e");
      emit(RootItemsState.error(
          prev: state, errorMsg: 'Failed to retrieve data: $e'));
    }
  }
}
