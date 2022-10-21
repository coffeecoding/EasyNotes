import 'package:bloc/bloc.dart';
import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/repositories/item_repository.dart';
import 'package:equatable/equatable.dart';

part 'items_state.dart';

class ItemsCubit extends Cubit<ItemsState> {
  ItemsCubit({required this.itemRepo, required this.selection})
      : super(const ItemsState.initial());

  final ItemRepository itemRepo;

  List<ItemCubit> get topicCubits => state.topicCubits;
  ItemCubit? get selectedTopic => state.selectedTopic;
  ItemCubit? get selectedNote => state.selectedNote;
  SelectionCubit selection;

  void selectTopic(int? i) => emit(ItemsState.changed(
      prev: state, selectedTopic: i == null ? null : topicCubits[i]));

  void selectChild(ItemCubit? item) {
    if (item != null && item.isTopic) {
      // only if the selected item is a subtopic, don't reselect the note
      item.expanded = !item.expanded;
      emit(ItemsState.changed(
          prev: state,
          didChildExpansionToggle: !state.didChildExpansionToggle,
          differentialRebuildNoteToggle: state.differentialRebuildNoteToggle));
    } else {
      selection.selectSingle(item);
      emit(ItemsState.changed(
          prev: state,
          selectedNote: item,
          didChildExpansionToggle: state.didChildExpansionToggle,
          differentialRebuildNoteToggle: !state.differentialRebuildNoteToggle));
    }
  }

  Future<void> fetchItems() async {
    try {
      final items = await itemRepo.fetchItems();
      final topicCubits =
          ItemCubit.createChildrenCubitsForParent(this, null, items);
      emit(ItemsState.loaded(topicCubits: topicCubits));
    } catch (e) {
      print("error in items_cubit fetchTopics: $e");
      emit(ItemsState.error(errorMsg: 'Failed to retrieve data: $e'));
    }
  }
}
