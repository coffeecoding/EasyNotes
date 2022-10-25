// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'children_items_cubit.dart';

enum ChildrenItemsStatus { unselected, busy, ready, error }

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
