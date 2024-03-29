// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'root_items_cubit.dart';

// two ready states to toggle between for minor state changes like
// pinning / unpinning an item actions like
// again, busySilent is needed when showing busy in the topic screen / modal
// already, which overlays the root items list view.
enum RootItemsStatus { busy, busySilent, ready, error }

enum ChildListVisibility { children, trash, search }

class RootItemsState extends Equatable {
  const RootItemsState._(
      {this.status = RootItemsStatus.busy,
      this.topicCubits = const <ItemVM>[],
      this.selectedItem,
      this.childListVisibility = ChildListVisibility.children,
      this.errorMsg = ''});

  const RootItemsState.initial() : this._();

  RootItemsState.busySilent({required RootItemsState prev})
      : this._(
          status: RootItemsStatus.busySilent,
          topicCubits: prev.topicCubits,
          selectedItem: prev.selectedItem,
          childListVisibility: prev.childListVisibility,
        );

  RootItemsState.busy({required RootItemsState prev})
      : this._(
          status: RootItemsStatus.busy,
          topicCubits: prev.topicCubits,
          selectedItem: prev.selectedItem,
          childListVisibility: prev.childListVisibility,
        );

  RootItemsState.ready({
    required RootItemsState prev,
    List<ItemVM>? topicCubits,
    ItemVM? selectedItem,
    ChildListVisibility? childListVisibility,
  }) : this._(
          status: RootItemsStatus.ready,
          topicCubits: topicCubits ?? prev.topicCubits,
          selectedItem: selectedItem,
          childListVisibility: childListVisibility ?? prev.childListVisibility,
        );

  RootItemsState.error({
    required RootItemsState prev,
    required String errorMsg,
  }) : this._(
            status: RootItemsStatus.error,
            topicCubits: prev.topicCubits,
            selectedItem: prev.selectedItem,
            childListVisibility: prev.childListVisibility,
            errorMsg: errorMsg);

  final RootItemsStatus status;
  final List<ItemVM> topicCubits;
  final ItemVM? selectedItem;
  final ChildListVisibility childListVisibility;
  final String errorMsg;

  @override
  List<Object?> get props =>
      [status, selectedItem, childListVisibility, topicCubits];
}
