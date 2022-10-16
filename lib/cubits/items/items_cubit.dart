import 'package:bloc/bloc.dart';
import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/repositories/item_repository.dart';
import 'package:equatable/equatable.dart';

part 'items_state.dart';

class ItemsCubit extends Cubit<ItemsState> {
  ItemsCubit({required this.itemRepo}) : super(const ItemsState.loading());

  final ItemRepository itemRepo;

  List<ItemCubit> get topicCubits => state.topicCubits;
  ItemCubit? get selectedTopic => state.selectedTopic;
  ItemCubit? get selectedNote => state.selectedNote;

  void selectTopic(int? i) => emit(ItemsState.success(
      prev: state, selectedTopic: i == null ? null : topicCubits[i]));

  void selectChild(ItemCubit? item) {
    if (item != null && item.isTopic) {
      // only if the selected item is a subtopic, don't reselect the note
      item.expanded = !item.expanded;
      emit(ItemsState.success(
          prev: state,
          didChildExpansionToggle: !state.didChildExpansionToggle));
    } else {
      emit(ItemsState.success(prev: state, selectedNote: item));
    }
  }

  Future<void> fetchItems() async {
    try {
      final items = await itemRepo.fetchItems();
      final topicCubits =
          ItemCubit.createChildrenCubitsForParent(this, null, items);
      emit(ItemsState.initial(topicCubits: topicCubits));
    } catch (e) {
      print("error in items_cubit fetchTopics: $e");
      emit(ItemsState.error(errorMsg: 'Failed to retrieve data: $e'));
    }
  }
}
