part of 'selected_note_cubit.dart';

class SelectedNoteState extends Equatable {
  const SelectedNoteState._({this.selectedNote});

  const SelectedNoteState.empty() : this._();

  const SelectedNoteState.persisted(ItemCubit note)
      : this._(selectedNote: note);

  const SelectedNoteState.newDraft(ItemCubit note) : this._(selectedNote: note);

  const SelectedNoteState.draft(ItemCubit note) : this._(selectedNote: note);

  const SelectedNoteState.busy(ItemCubit note) : this._(selectedNote: note);

  const SelectedNoteState.error(ItemCubit note) : this._(selectedNote: note);

  final ItemCubit? selectedNote;
  ItemStatus? get status => selectedNote?.status;

  @override
  List<Object?> get props => [status, selectedNote];
}
