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
      String title = note!.titleField;
      String content = note!.contentField;
      emit(SelectedNoteState.changed(
          status: SelectedNoteStatus.busy, note: note));
      final success = await note!.save(title: title, content: content);
      if (success) {
        emit(SelectedNoteState.changed(
            status: _mapItemStatusToEmptyable(note), note: note));
      } else {
        print("error saving item (no success)");
        emit(SelectedNoteState.changed(
            status: SelectedNoteStatus.error, note: note));
      }
    } catch (e) {
      print("error saving item: $e");
      emit(SelectedNoteState.changed(
          status: SelectedNoteStatus.error, note: note));
    }
  }

  void update(ItemCubit? note) => emit(SelectedNoteState.changed(
      status: _mapItemStatusToEmptyable(note), note: note));

  SelectedNoteStatus _mapItemStatusToEmptyable(ItemCubit? note) {
    if (note != null) {
      switch (note.status) {
        case ItemStatus.busy:
          return SelectedNoteStatus.busy;
        case ItemStatus.draft:
          return SelectedNoteStatus.draft;
        case ItemStatus.error:
          return SelectedNoteStatus.error;
        case ItemStatus.newDraft:
          return SelectedNoteStatus.newDraft;
        case ItemStatus.persisted:
          return SelectedNoteStatus.persisted;
      }
    }
    return SelectedNoteStatus.empty;
  }
}
