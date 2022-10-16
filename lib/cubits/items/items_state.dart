// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'items_cubit.dart';

enum ItemsStatus { loading, initial, success, error }

class ItemsState extends Equatable {
  const ItemsState._(
      {this.status = ItemsStatus.loading,
      this.topicCubits = const <ItemCubit>[],
      this.selectedTopic,
      this.selectedNote,
      this.didChildExpansionToggle = false,
      this.errorMsg = ''});

  const ItemsState.loading() : this._();

  const ItemsState.initial(
      {required List<ItemCubit> topicCubits,
      ItemCubit? selectedTopic,
      ItemCubit? selectedNote})
      : this._(
          status: ItemsStatus.initial,
          topicCubits: topicCubits,
          selectedTopic: selectedTopic,
          selectedNote: selectedNote,
        );

  ItemsState.success(
      {required ItemsState prev,
      List<ItemCubit>? topicCubits,
      ItemCubit? selectedTopic,
      ItemCubit? selectedNote,
      bool? didChildExpansionToggle})
      : this._(
          status: ItemsStatus.success,
          topicCubits: topicCubits ?? prev.topicCubits,
          selectedTopic: selectedTopic ?? prev.selectedTopic,
          selectedNote: selectedNote ?? prev.selectedNote,
          didChildExpansionToggle:
              didChildExpansionToggle ?? prev.didChildExpansionToggle,
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
  final String errorMsg;

  @override
  List<Object?> get props => [
        status,
        didChildExpansionToggle,
        selectedTopic,
        selectedNote,
        topicCubits
      ];
}
