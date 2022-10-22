import 'package:bloc/bloc.dart';
import 'package:easynotes/cubits/item/item_cubit.dart';
import 'package:equatable/equatable.dart';

part 'selected_note_state.dart';

class SelectedNoteCubit extends Cubit<SelectedNoteState> {
  SelectedNoteCubit() : super(const SelectedNoteState.empty());

  // Todo: add QoL feature:
  // - add dependency on preferences
  // - store last selected note (and topic) in prefs when app closes
  // - restore that selection from prefs and initialize this cubit
  //   with the last selection

  ItemCubit? get note => state.selectedNote;

  Future<void> save() async {
    try {
      emit(SelectedNoteState.busy(note!));
      final success = await note!.save();
      if (!success) {
        print("error saving item (no success)");
        emit(SelectedNoteState.error(note!));
      } else {
        handleChanged();
      }
    } catch (e) {
      print("error saving item: $e");
      emit(SelectedNoteState.error(note!));
    }
  }

  void resetState() {
    note!.resetState();
    handleChanged();
  }

  void saveLocalState(
      {ItemStatus? newStatus,
      required String titleField,
      required String contentField}) {
    note!.saveLocalState(
        newStatus: newStatus,
        titleField: titleField,
        contentField: contentField);
    handleChanged();
  }

  void handleChanged() {
    update(note);
  }

  void update(ItemCubit? note) {
    if (note == null) return emit(const SelectedNoteState.empty());
    switch (note.status) {
      case ItemStatus.busy:
        return emit(SelectedNoteState.busy(note));
      case ItemStatus.draft:
        return emit(SelectedNoteState.draft(note));
      case ItemStatus.error:
        return emit(SelectedNoteState.error(note));
      case ItemStatus.newDraft:
        return emit(SelectedNoteState.newDraft(note));
      case ItemStatus.persisted:
        return emit(SelectedNoteState.persisted(note));
    }
  }
}
