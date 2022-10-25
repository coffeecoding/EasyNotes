import 'package:bloc/bloc.dart';
import 'package:easynotes/cubits/item/item_cubit.dart';
import 'package:easynotes/cubits/items/items_cubit.dart';
import 'package:easynotes/repositories/item_repository.dart';
import 'package:equatable/equatable.dart';

part 'trash_state.dart';

class TrashCubit extends Cubit<TrashState> {
  TrashCubit({
    required this.itemRepo,
    required this.itemsCubit,
    this.itemCubits = const <ItemCubit>[],
  }) : super(const TrashState.busy());

  final ItemRepository itemRepo;
  final ItemsCubit itemsCubit;
  List<ItemCubit> itemCubits;

  void sort() {
    itemCubits.sort((a, b) => a.item.trashed!.compareTo(b.item.trashed!));
  }

  void initialize() {
    final items = itemRepo.getTrashedItems();
    final topLevelItems = items
        .where((i) =>
            i.parent_id == null || !items.any((p) => p.id == i.parent_id))
        .toList();
    items.removeWhere((i) => topLevelItems.contains(i));
    items.forEach((i) {});
    //itemCubits =
    //    ItemCubit.createChildrenCubitsForParent(itemsCubit, parent, items);
  }
}
