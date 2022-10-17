// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'items_cubit.dart';

enum ItemsStatus { busy, loaded, changed, error }

class ItemsState extends Equatable {
  const ItemsState._(
      {this.status = ItemsStatus.busy,
      this.topicCubits = const <ItemCubit>[],
      this.selectedTopic,
      this.selectedNote,
      this.differentialRebuildToggle = false,
      this.errorMsg = ''});

  const ItemsState.busy() : this._();

  const ItemsState.loaded({
    required List<ItemCubit> topicCubits,
    ItemCubit? selectedTopic,
    ItemCubit? selectedNote,
    required bool differentialRebuildToggle,
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
      bool? differentialRebuildToggle})
      : this._(
          status: ItemsStatus.changed,
          topicCubits: topicCubits ?? prev.topicCubits,
          selectedTopic: selectedTopic ?? prev.selectedTopic,
          selectedNote: selectedNote ?? prev.selectedNote,
          differentialRebuildToggle:
              differentialRebuildToggle ?? prev.differentialRebuildToggle,
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
  //final bool didChildExpansionToggle;
  //final bool didSelectedNoteChangeToggle;
  final bool differentialRebuildToggle;

  final String errorMsg;

  @override
  List<Object?> get props => [
        status,
        differentialRebuildToggle,
        selectedTopic,
        selectedNote,
        topicCubits
      ];
}
