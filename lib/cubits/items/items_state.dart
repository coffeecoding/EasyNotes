// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'items_cubit.dart';

enum ItemsStatus { loading, initial, success, error }

class ItemsState extends Equatable {
  const ItemsState._(
      {this.status = ItemsStatus.loading,
      this.topicCubits = const <ItemCubit>[],
      this.selectedTopic,
      this.selectedSubTopic,
      this.selectedNote,
      this.errorMsg = ''});

  const ItemsState.loading() : this._();

  ItemsState.initial(
      {required List<ItemCubit> topicCubits,
      ItemCubit? selectedTopic,
      ItemCubit? selectedSubTopic,
      ItemCubit? selectedNote})
      : this._(
          status: ItemsStatus.initial,
          topicCubits: topicCubits,
          selectedTopic: selectedTopic,
          selectedSubTopic: selectedSubTopic,
          selectedNote: selectedNote,
        );

  ItemsState.success(
      {required ItemsState prev,
      List<ItemCubit>? topicCubits,
      ItemCubit? selectedTopic,
      ItemCubit? selectedSubTopic,
      ItemCubit? selectedNote})
      : this._(
          status: ItemsStatus.success,
          topicCubits: topicCubits ?? prev.topicCubits,
          selectedTopic: selectedTopic ?? prev.selectedTopic,
          selectedSubTopic: selectedSubTopic ?? prev.selectedSubTopic,
          selectedNote: selectedNote ?? prev.selectedSubTopic,
        );

  // potentially pass previous state as well, to keep the UI state
  const ItemsState.error({required String errorMsg})
      : this._(status: ItemsStatus.error, errorMsg: errorMsg);

  final ItemsStatus status;
  final List<ItemCubit> topicCubits;
  final ItemCubit? selectedTopic;
  final ItemCubit? selectedSubTopic;
  final ItemCubit? selectedNote;
  final String errorMsg;

  @override
  List<Object?> get props =>
      [status, selectedTopic, selectedSubTopic, selectedNote, topicCubits];
}
