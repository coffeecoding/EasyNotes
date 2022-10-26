import 'package:bloc/bloc.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:easynotes/cubits/root_items/root_items_cubit.dart';
import 'package:easynotes/repositories/item_repository.dart';
import 'package:equatable/equatable.dart';

part 'trash_state.dart';

class TrashCubit extends Cubit<TrashState> with ListWithSelectionCubit {
  TrashCubit({
    required this.itemRepo,
    required this.rootItemsCubit,
    this.itemVMs = const <ItemVM>[],
  }) : super(const TrashState.busy());

  final ItemRepository itemRepo;
  final RootItemsCubit rootItemsCubit;
  List<ItemVM> itemVMs;

  void sort() {
    itemVMs.sort((a, b) => a.item.trashed!.compareTo(b.item.trashed!));
  }

  void initialize() {
    final items = itemRepo.getTrashedItems();
    final topLevelItems = items
        .where((i) =>
            i.parent_id == null || !items.any((p) => p.id == i.parent_id))
        .toList();
    items.removeWhere((i) => topLevelItems.contains(i));
    items.forEach((i) {});
    //ItemVMs =
    //    ItemVM.createChildrenCubitsForParent(RootItemsCubit, parent, items);
  }

  @override
  void addItem(ItemVM item) {
    // TODO: implement addItem
  }

  @override
  Future<void> fetchItems() {
    // TODO: implement fetchItems
    throw UnimplementedError();
  }

  @override
  void handleError(Object e) {
    // TODO: implement handleError
  }

  @override
  void handleItemsChanged() {
    // TODO: implement handleItemsChanged
  }

  @override
  void handleItemsChanging({bool silent = false}) {
    // TODO: implement handleItemsChanging
  }

  @override
  void handleSelectionChanged(ItemVM? selected) {
    // TODO: implement handleSelectionChanged
  }

  @override
  void insertItem(ItemVM item) {
    // TODO: implement insertItem
  }

  @override
  void removeItem(ItemVM item) {
    // TODO: implement removeItem
  }
}
