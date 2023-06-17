import 'package:bloc/bloc.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:easynotes/cubits/root_items/root_items_cubit.dart';
import 'package:easynotes/models/item.dart';
import 'package:easynotes/repositories/item_repository.dart';
import 'package:equatable/equatable.dart';

part 'trashed_items_state.dart';

class TrashedItemsCubit extends Cubit<TrashedItemsState>
    with ListWithSelectionCubit {
  TrashedItemsCubit({
    required this.itemRepo,
  }) : super(const TrashedItemsState.initial());

  final ItemRepository itemRepo;

  List<ItemVM> get items => state.items;
  String? errorMsg;

  void sort() {
    items.sort((a, b) => a.item.trashed!.compareTo(b.item.trashed!));
  }

  void reloadLocally() {
    final trashRoot = ItemVM(
        item: Item.empty(parent_id: null, type: 0, receiver_id: ''),
        parent: null,
        items: []);
    final items = itemRepo.getItems();
    // go through all leaves in trashed items (item w no children)
    final roots = ItemVM.createChildrenCubitsForParent(null, items.toList());
    trashRoot.children = roots;
    for (var r in roots) {
      r.parent = trashRoot;
    }
    final subtrees = trashRoot
        .getDescendantsRecursive()
        .where((i) => i.parent!.trashed == null && i.trashed != null)
        .toList();
    emit(TrashedItemsState.ready(prev: state, items: subtrees));
  }

  Future<void> deleteAll() async {
    try {
      await itemRepo.deleteItems(items.map((e) => e.id).toList());
    } catch (e) {
      print('failed to delete all items: $e');
      emit(TrashedItemsState.error(prev: state));
    }
  }

  @override
  void addItem(ItemVM item) {
    insertItem(item, items.length);
    // todo: sort by preference (date trashed)
  }

  @override
  Future<void> fetchItems() {
    // Todo: implement fetchItems
    throw UnimplementedError();
  }

  @override
  void handleError(Object e) {
    errorMsg = e.toString();
    emit(TrashedItemsState.error(prev: state));
  }

  @override
  void handleItemsChanged({List<ItemVM>? items, bool reload = false}) {
    if (reload) {
      reloadLocally();
    } else {
      emit(TrashedItemsState.ready(prev: state, items: items));
    }
  }

  @override
  void handleItemsChanging({bool silent = false}) {
    if (silent) {
      emit(TrashedItemsState.busySilent(prev: state));
    } else {
      emit(TrashedItemsState.busy(prev: state));
    }
  }

  @override
  void handleSelectionChanged(ItemVM? selected,
      [ChildListVisibility childListVisibility =
          ChildListVisibility.children]) {
    emit(TrashedItemsState.ready(prev: state));
  }

  @override
  void insertItem(ItemVM item, [int idx = 0]) {
    items.insert(idx, item);
    // recreate tree structure, because a descendant might be added after one
    // of its ancestors
    item.reloadFromRepo();
    // todo: sort by preference (date trashed)
  }

  @override
  void removeItem(ItemVM item) {
    items.remove(item);
  }
}
