import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:easynotes/cubits/item/item_cubit.dart';

part 'selection_state.dart';

class SelectionCubit extends Cubit<SelectionState> {
  SelectionCubit() : super(const SelectionState.empty());

  // Todo: add QoL feature:
  // - add dependency on preferences
  // - store last selected note (and topic) in prefs when app closes
  // - restore that selection from prefs and initialize this cubit
  //   with the last selection

  ItemCubit? get note => state.selection.isEmpty ? null : state.selection.first;
  List<ItemCubit> get selection => state.selection;

  void selectSingle(ItemCubit? note) =>
      emit(SelectionState.changedSingle(note));

  void selectMultiple(List<ItemCubit> notes) =>
      emit(SelectionState.changedMultiple(notes));
}
