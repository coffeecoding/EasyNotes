import 'package:bloc/bloc.dart';
import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/repositories/item_repository.dart';
import 'package:equatable/equatable.dart';

part 'items_state.dart';

class ItemsCubit extends Cubit<ItemsState> {
  ItemsCubit({required this.itemRepo}) : super(const ItemsState.busy());

  final ItemRepository itemRepo;

  List<ItemCubit> get topicCubits => state.topicCubits;
  ItemCubit? get selectedTopic => state.selectedTopic;
  ItemCubit? get selectedNote => state.selectedNote;

  void selectTopic(int? i) => emit(ItemsState.changed(
      prev: state, selectedTopic: i == null ? null : topicCubits[i]));

  void selectChild(ItemCubit? item) {
    if (item != null && item.isTopic) {
      // only if the selected item is a subtopic, don't reselect the note
      item.expanded = !item.expanded;
      emit(ItemsState.changed(
          prev: state,
          differentialRebuildToggle: !state.differentialRebuildToggle));
    } else {
      emit(ItemsState.changed(
          prev: state,
          selectedNote: item,
          differentialRebuildToggle: !state.differentialRebuildToggle));
    }
  }

  Future<void> fetchItems() async {
    try {
      final items = await itemRepo.fetchItems();
      final topicCubits =
          ItemCubit.createChildrenCubitsForParent(this, null, items);
      emit(ItemsState.loaded(
          topicCubits: topicCubits, differentialRebuildToggle: true));
    } catch (e) {
      print("error in items_cubit fetchTopics: $e");
      emit(ItemsState.error(errorMsg: 'Failed to retrieve data: $e'));
    }
  }
}
