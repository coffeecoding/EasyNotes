// ignore_for_file: avoid_print

import 'package:bloc/bloc.dart';
import 'package:easynotes/cubits/children_items/children_items_cubit.dart';
import 'package:easynotes/cubits/item_vm/item_vm.dart';
import 'package:equatable/equatable.dart';

part 'selected_note_state.dart';

class SelectedNoteCubit extends Cubit<SelectedNoteState> {
  SelectedNoteCubit({required this.childrenItemsCubit})
      : super(const SelectedNoteState.empty());

  // Todo: add QoL feature:
  // - add dependency on preferences
  // - store last selected note (and topic) in prefs when app closes
  // - restore that selection from prefs and initialize this cubit
  //   with the last selection

  final ChildrenItemsCubit childrenItemsCubit;

  ItemVM? get note => state.selectedNote;

  Future<void> save({
    String? titleField,
    String? contentField,
    String? colorSelection,
  }) async {
    try {
      emit(SelectedNoteState.busy(note!));
      final success = await note!.save(
          titleField: titleField,
          contentField: contentField,
          colorSelection: colorSelection);
      if (!success) {
        print("error saving item (no success)");
        emit(SelectedNoteState.error(note!));
      } else {
        emit(SelectedNoteState.persisted(note!));
      }
    } catch (e) {
      print("error saving item: $e");
      emit(SelectedNoteState.error(note!));
    }
  }

  void resetState() {
    note!.resetState();
    if (note?.status == ItemVMStatus.newDraft) {
      handleNoteChanged(null);
    } else {
      handleNoteChanged(note);
    }
    childrenItemsCubit.handleItemsChanged();
  }

  void saveLocalState(
      {ItemVMStatus? newStatus,
      required String titleField,
      required String contentField,
      FocussedElement? focussedElement}) {
    note!.saveLocalState(
        newStatus: newStatus,
        titleField: titleField,
        contentField: contentField,
        focussedElement: focussedElement);
    handleNoteChanged(note);
  }

  void handleNoteChanged(ItemVM? note) {
    if (note == null) return emit(const SelectedNoteState.empty());
    switch (note.status) {
      case ItemVMStatus.busy:
        return emit(SelectedNoteState.busy(note));
      case ItemVMStatus.draft:
        return emit(SelectedNoteState.draft(note));
      case ItemVMStatus.error:
        return emit(SelectedNoteState.error(note));
      case ItemVMStatus.newDraft:
        return emit(SelectedNoteState.newDraft(note));
      case ItemVMStatus.persisted:
        return emit(SelectedNoteState.persisted(note));
    }
  }
}
