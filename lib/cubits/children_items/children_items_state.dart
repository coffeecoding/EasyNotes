// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'children_items_cubit.dart';

// busySilent: Sometimes we want to be in a busy state but not display it
// over this view as it the busy state may already be shown in an overlaying
// view. Example: when pinning item, the individual item is showing busy state,
// so no need to view busy state on the whole children items list as well, but
// we still need busy state because otherwise the children list won't update;
// The only way to avoid the need for this extra status would be if we could
// switch from ready(originalList) -> ready(changedList) and it would still
// update, but it's not working. So the current solution to update the list
// view on change of items in the list is to do the state change as follows:
// ready(list) -> busy(list) -> ready(list)  // when we want to diplay busy, or
// ready(list) -> busySilent(list) -> ready(list)
enum ChildrenItemsStatus { unselected, busy, busySilent, ready, error }

class ChildrenItemsState extends Equatable {
  const ChildrenItemsState._(
      {this.status = ChildrenItemsStatus.unselected,
      this.childrenCubits = const <ItemVM>[],
      this.selectedNote,
      this.errorMsg = ''});

  const ChildrenItemsState.initial() : this._();

  ChildrenItemsState.busy({required ChildrenItemsState prev})
      : this._(
          status: ChildrenItemsStatus.busy,
          childrenCubits: prev.childrenCubits,
          selectedNote: prev.selectedNote,
        );

  ChildrenItemsState.busySilent({required ChildrenItemsState prev})
      : this._(
          status: ChildrenItemsStatus.busySilent,
          childrenCubits: prev.childrenCubits,
          selectedNote: prev.selectedNote,
        );

  ChildrenItemsState.ready({
    required ChildrenItemsState prev,
    List<ItemVM>? childrenCubits,
    ItemVM? selectedNote,
  }) : this._(
          status: ChildrenItemsStatus.ready,
          childrenCubits: childrenCubits ?? prev.childrenCubits,
          selectedNote: selectedNote,
        );

  ChildrenItemsState.error({
    required ChildrenItemsState prev,
    required String errorMsg,
  }) : this._(
            status: ChildrenItemsStatus.error,
            childrenCubits: prev.childrenCubits,
            selectedNote: prev.selectedNote,
            errorMsg: errorMsg);

  final ChildrenItemsStatus status;
  final List<ItemVM> childrenCubits;
  final ItemVM? selectedNote;
  final String errorMsg;

  @override
  List<Object?> get props => [status, selectedNote, childrenCubits];
}
