import 'package:bloc/bloc.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:easynotes/cubits/root_items/root_items_cubit.dart';
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

  void initialize() {
    final items = itemRepo.getTrashedItems();
    final topLevelItems = items
        .where((i) =>
            i.parent_id == null || !items.any((p) => p.id == i.parent_id))
        .toList();
    items.removeWhere((i) => topLevelItems.contains(i));
  }

  @override
  void addItem(ItemVM item) {
    items.add(item);
    // todo: sort by preference (date trashed)
  }

  @override
  Future<void> fetchItems() {
    // TODO: implement fetchItems
    throw UnimplementedError();
  }

  @override
  void handleError(Object e) {
    errorMsg = e.toString();
    emit(TrashedItemsState.error(prev: state));
  }

  @override
  void handleItemsChanged({List<ItemVM>? items}) {
    emit(TrashedItemsState.ready(prev: state, items: items));
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
  void handleSelectionChanged(ItemVM? selected, [bool selectTrash = false]) {
    emit(TrashedItemsState.ready(prev: state));
  }

  @override
  void insertItem(ItemVM item) {
    items.insert(0, item);
    // todo: sort by preference (date trashed)
  }

  @override
  void removeItem(ItemVM item) {
    items.remove(item);
  }
}
