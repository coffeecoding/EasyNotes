import 'package:bloc/bloc.dart';
import 'package:easynotes/config/constants.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:easynotes/cubits/root_items/root_items_cubit.dart';
import 'package:easynotes/models/item.dart';
import 'package:easynotes/repositories/item_repository.dart';
import 'package:equatable/equatable.dart';

part 'children_items_state.dart';

class ChildrenItemsCubit extends Cubit<ChildrenItemsState>
    with ListWithSelectionCubit {
  ChildrenItemsCubit({required this.itemRepo, required this.rootItemsCubit})
      : super(const ChildrenItemsState.initial());

  final ItemRepository itemRepo;

  final RootItemsCubit rootItemsCubit;
  List<ItemVM> get childrenCubits => state.childrenCubits;
  ItemVM? get selectedNote => state.selectedNote;

  @override
  void addItem(ItemVM item) {
    childrenCubits.add(item);
    handleItemsChanged();
  }

  @override
  void insertItem(ItemVM item) {
    childrenCubits.insert(0, item);
    handleItemsChanged();
  }

  @override
  void removeItem(ItemVM item) {
    childrenCubits.remove(item);
    handleItemsChanged();
  }

  void handleRootItemSelectionChanged(ItemVM? rootItem) {
    emit(ChildrenItemsState.ready(
        prev: state, childrenCubits: rootItem?.children ?? []));
  }

  @override
  void handleSelectionChanged(ItemVM? selected) {
    emit(ChildrenItemsState.ready(prev: state, selectedNote: selected));
  }

  @override
  void handleItemsChanging() {
    emit(ChildrenItemsState.busy(prev: state));
  }

  @override
  void handleItemsChanged() {
    emit(ChildrenItemsState.ready(prev: state));
  }

  @override
  void handleError(Object e) {
    emit(ChildrenItemsState.error(
        prev: state, errorMsg: 'Failed to retrieve data: $e'));
  }

  Future<void> createNote(ItemVM parent) async {
    ItemVM newNote = await _createItem(parent, 1);
    parent.expanded = true;
    parent.insertChildAtTop(newNote);
    //return newNote;
  }

  Future<void> createSubTopic(ItemVM parent) async {
    ItemVM newTopic = await _createItem(parent, 0);
    parent.expanded = true;
    parent.insertChildAtTop(newTopic);
    //return newTopic;
  }

  Future<ItemVM> _createItem(ItemVM? parent, int type) async {
    Item newItem = await itemRepo.createNewItem(
        parent_id: parent?.id,
        color: parent?.color ?? defaultItemColor,
        type: type);
    ItemVM newCubit = ItemVM(
        item: newItem,
        items: [],
        parentListCubit: this,
        parent: parent,
        expanded: false);
    return newCubit;
  }

  // Todo: implement
  @override
  Future<void> fetchItems() async {
    throw 'not implemented';
  }
}
