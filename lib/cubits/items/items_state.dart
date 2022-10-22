// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'items_cubit.dart';

enum ItemsStatus { initial, busy, loading, loaded, changed, error }

class ItemsState extends Equatable {
  const ItemsState._(
      {this.status = ItemsStatus.busy,
      this.topicCubits = const <ItemCubit>[],
      this.selectedTopic,
      this.selectedNote,
      this.didChildExpansionToggle = false,
      this.differentialRebuildNoteToggle = false,
      this.errorMsg = ''});

  const ItemsState.initial() : this._();

  ItemsState.loading({required ItemsState prev})
      : this._(
          status: ItemsStatus.loading,
          topicCubits: prev.topicCubits,
          selectedTopic: prev.selectedTopic,
          selectedNote: prev.selectedNote,
          didChildExpansionToggle: prev.didChildExpansionToggle,
          differentialRebuildNoteToggle: prev.differentialRebuildNoteToggle,
        );

  ItemsState.busy({required ItemsState prev})
      : this._(
          status: ItemsStatus.busy,
          topicCubits: prev.topicCubits,
          selectedTopic: prev.selectedTopic,
          selectedNote: prev.selectedNote,
          didChildExpansionToggle: prev.didChildExpansionToggle,
          differentialRebuildNoteToggle: prev.differentialRebuildNoteToggle,
        );

  const ItemsState.loaded({
    required List<ItemCubit> topicCubits,
    ItemCubit? selectedTopic,
    ItemCubit? selectedNote,
  }) : this._(
          status: ItemsStatus.loaded,
          topicCubits: topicCubits,
          selectedTopic: selectedTopic,
          selectedNote: selectedNote,
        );

  ItemsState.changed(
      {required ItemsState prev,
      List<ItemCubit>? topicCubits,
      ItemCubit? selectedTopic,
      ItemCubit? selectedNote,
      bool? didChildExpansionToggle,
      bool? differentialRebuildNoteToggle})
      : this._(
          status: ItemsStatus.changed,
          topicCubits: topicCubits ?? prev.topicCubits,
          selectedTopic: selectedTopic ?? prev.selectedTopic,
          selectedNote: selectedNote ?? prev.selectedNote,
          didChildExpansionToggle:
              didChildExpansionToggle ?? prev.didChildExpansionToggle,
          differentialRebuildNoteToggle: differentialRebuildNoteToggle ??
              prev.differentialRebuildNoteToggle,
        );

  // potentially pass previous state as well, to keep the UI state
  const ItemsState.error({required String errorMsg})
      : this._(status: ItemsStatus.error, errorMsg: errorMsg);

  final ItemsStatus status;
  final List<ItemCubit> topicCubits;
  final ItemCubit? selectedTopic;
  final ItemCubit? selectedNote;
  // boolean to toggle whenever a child item gets expanded/collapsed,
  // so this flag can be used to discern wh ther to rebuild the item
  // listview
  final bool didChildExpansionToggle;
  final bool differentialRebuildNoteToggle;

  final String errorMsg;

  @override
  List<Object?> get props => [
        status,
        didChildExpansionToggle,
        differentialRebuildNoteToggle,
        selectedTopic,
        selectedNote,
        topicCubits
      ];
}
