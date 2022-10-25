// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'root_items_cubit.dart';

// two ready states to toggle between for minor state changes like
// pinning / unpinning an item actions like
enum RootItemsStatus { busy, ready, error }
// other idea: separate status of children and root items
// enum RootItemVMStatus { busy, ready, error }
// enum ChildrenStatus { busy, ready, error }

class RootItemsState extends Equatable {
  const RootItemsState._(
      {this.status = RootItemsStatus.busy,
      this.topicCubits = const <ItemVM>[],
      this.selectedTopic,
      this.errorMsg = ''});

  const RootItemsState.initial() : this._();

  RootItemsState.busy({required RootItemsState prev})
      : this._(
          status: RootItemsStatus.busy,
          topicCubits: prev.topicCubits,
          selectedTopic: prev.selectedTopic,
        );

  RootItemsState.ready({
    required RootItemsState prev,
    List<ItemVM>? topicCubits,
    ItemVM? selectedTopic,
  }) : this._(
          status: RootItemsStatus.ready,
          topicCubits: topicCubits ?? prev.topicCubits,
          selectedTopic: selectedTopic,
        );

  RootItemsState.error({
    required RootItemsState prev,
    required String errorMsg,
  }) : this._(
            status: RootItemsStatus.error,
            topicCubits: prev.topicCubits,
            selectedTopic: prev.selectedTopic,
            errorMsg: errorMsg);

  final RootItemsStatus status;
  final List<ItemVM> topicCubits;
  final ItemVM? selectedTopic;
  final String errorMsg;

  @override
  List<Object?> get props => [status, selectedTopic, topicCubits];
}
