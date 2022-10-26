import 'package:bloc/bloc.dart';
import 'package:easynotes/config/constants.dart';
import 'package:easynotes/cubits/children_items/children_items_cubit.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:easynotes/models/item.dart';
import 'package:easynotes/repositories/item_repository.dart';
import 'package:equatable/equatable.dart';

part 'root_items_state.dart';

abstract class ListWithSelectionCubit {
  void addItem(ItemVM item);
  void insertItem(ItemVM item);
  void removeItem(ItemVM item);
  void handleItemsChanging();
  void handleItemsChanged();
  void handleSelectionChanged(ItemVM? selected);
  void handleError(Object e);
  Future<void> fetchItems();
}

class RootItemsCubit extends Cubit<RootItemsState> with ListWithSelectionCubit {
  RootItemsCubit({required this.itemRepo, required this.childrenItemsCubit})
      : super(const RootItemsState.initial());

  final ItemRepository itemRepo;

  final ChildrenItemsCubit childrenItemsCubit;

  List<ItemVM> get topicCubits => state.topicCubits;
  ItemVM? get selectedItem => state.selectedItem;

  @override
  void handleSelectionChanged(ItemVM? selected) =>
      emit(RootItemsState.ready(prev: state, selectedItem: selected));

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
    ItemVM newCubit = ItemVM(
        item: newItem,
        items: [],
        parentListCubit: this,
        parent: null,
        expanded: false);
    return newCubit;
  }

  @override
  void handleItemsChanging() {
    emit(RootItemsState.busy(prev: state));
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
      ChildCubitCreator.init(
          rootItemsCubit: this, childrenItemsCubit: childrenItemsCubit);
      final topicCubits =
          ChildCubitCreator.createChildrenCubitsForParent(null, items);
      emit(RootItemsState.ready(prev: state, topicCubits: topicCubits));
    } catch (e) {
      print("error in items_cubit fetchTopics: $e");
      emit(RootItemsState.error(
          prev: state, errorMsg: 'Failed to retrieve data: $e'));
    }
  }
}
