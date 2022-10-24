import 'package:bloc/bloc.dart';
import 'package:easynotes/config/constants.dart';
import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/cubits/selected_note/selected_note_cubit.dart';
import 'package:easynotes/models/item.dart';
import 'package:easynotes/repositories/item_repository.dart';
import 'package:equatable/equatable.dart';

part 'items_state.dart';

class ItemsCubit extends Cubit<ItemsState> {
  ItemsCubit(
      {required this.itemRepo,
      required this.selectedNoteCubit,
      required this.topicScreenCubit})
      : super(const ItemsState.initial());

  final ItemRepository itemRepo;

  List<ItemCubit> get topicCubits => state.topicCubits;
  ItemCubit? get selectedTopic => state.selectedTopic;
  ItemCubit? get selectedNote => state.selectedNote;
  SelectedNoteCubit selectedNoteCubit;
  TopicCubit topicScreenCubit;

  void selectTopic(int? i) => emit(ItemsState.changed(
      prev: state, selectedTopic: i == null ? null : topicCubits[i]));

  void selectTopicDirectly(ItemCubit? topic) =>
      emit(ItemsState.changed(prev: state, selectedTopic: topic));

  void selectChild(ItemCubit? item) {
    if (item != null && item.isTopic) {
      // only if the selected item is a subtopic, don't reselect the note
      item.expanded = !item.expanded;
      emit(ItemsState.changed(
          prev: state,
          didChildExpansionToggle: !state.didChildExpansionToggle,
          differentialRebuildNoteToggle: state.differentialRebuildNoteToggle));
    } else {
      handleSelectedNoteChanged(item);
    }
  }

  void addTopic(ItemCubit topicCubit) {
    // todo : apply preferred sorting
    topicCubits.add(topicCubit);
  }

  void removeTopic(ItemCubit topicCubit) {
    // todo : apply preferred sorting
    topicCubits.remove(topicCubit);
  }

  void insertTopicInTop(ItemCubit topicCubit) {
    topicCubits.insert(0, topicCubit);
    handleRootItemsChanged();
  }

  void createSubTopic(ItemCubit? parent) async {
    ItemCubit newTopic = await createItem(parent ?? selectedTopic, 0);
    if (parent == null) {
      selectedTopic!.insertChildAtTop(newTopic);
    } else {
      parent.insertChildAtTop(newTopic);
    }
    handleItemsChanged();
  }

  void createNote(ItemCubit? parent) async {
    ItemCubit newNote = await createItem(parent ?? selectedTopic, 1);
    if (parent == null) {
      selectedTopic!.insertChildAtTop(newNote);
    } else {
      parent.insertChildAtTop(newNote);
    }
    handleItemsChanged();
  }

  Future<ItemCubit> createItem(ItemCubit? parent, int type) async {
    Item newItem = await itemRepo.createNewItem(
        parent_id: parent?.id,
        color: parent?.color ?? defaultItemColor,
        type: type);
    ItemCubit newCubit = ItemCubit(
        item: newItem,
        items: [],
        itemsCubit: this,
        parent: parent,
        expanded: false);
    /*if (parent == null) {
      addTopic(newCubit);
    } else {
      parent.addChild(newCubit);
    }
    selectChild(newCubit);
    handleItemsChanged();
    if (!newItem.isTopic) {
      handleSelectedNoteChanged(newCubit);
    } else {
      topicScreenCubit.select(newCubit);
    }*/
    return newCubit;
  }

  void handleRootItemsChanged() {
    emit(ItemsState.changed(
        prev: state,
        topicCubits: state.topicCubits,
        didChildExpansionToggle: state.didChildExpansionToggle,
        differentialRebuildNoteToggle: !state.differentialRebuildNoteToggle));
  }

  void handleItemsChanged() {
    emit(ItemsState.changed(
        prev: state,
        selectedNote: selectedNote,
        didChildExpansionToggle: state.didChildExpansionToggle,
        differentialRebuildNoteToggle: !state.differentialRebuildNoteToggle));
  }

  void handleSelectedNoteChanged(ItemCubit? note) {
    emit(ItemsState.changed(
        prev: state,
        selectedNote: note,
        didChildExpansionToggle: state.didChildExpansionToggle,
        differentialRebuildNoteToggle: !state.differentialRebuildNoteToggle));
    selectedNoteCubit.update(null);
    selectedNoteCubit.update(note);
  }

  Future<void> fetchItems() async {
    try {
      emit(ItemsState.loading(prev: state));
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
