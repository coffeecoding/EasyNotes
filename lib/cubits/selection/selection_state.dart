part of 'selection_cubit.dart';

enum SelectionStatus { empty, single, multi }

class SelectionState extends Equatable {
  const SelectionState._(
      {this.status = SelectionStatus.empty, this.selection = const []});

  const SelectionState.empty() : this._();

  SelectionState.changedSingle(ItemCubit? newSelection)
      : this._(
            status: SelectionStatus.single,
            selection: newSelection == null ? [] : [newSelection]);

  const SelectionState.changedMultiple(List<ItemCubit> newSelection)
      : this._(status: SelectionStatus.multi, selection: newSelection);

  final SelectionStatus status;
  final List<ItemCubit> selection;

  @override
  List<Object> get props => [status, selection];
}
