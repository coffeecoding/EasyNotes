part of 'selected_note_cubit.dart';

class SelectedNoteState extends Equatable {
  const SelectedNoteState._({this.selectedNote, this.status});

  const SelectedNoteState.empty() : this._();

  const SelectedNoteState.persisted(ItemCubit note)
      : this._(status: ItemStatus.persisted, selectedNote: note);

  const SelectedNoteState.newDraft(ItemCubit note)
      : this._(status: ItemStatus.newDraft, selectedNote: note);

  const SelectedNoteState.draft(ItemCubit note)
      : this._(status: ItemStatus.draft, selectedNote: note);

  const SelectedNoteState.busy(ItemCubit note)
      : this._(status: ItemStatus.busy, selectedNote: note);

  const SelectedNoteState.error(ItemCubit note)
      : this._(status: ItemStatus.error, selectedNote: note);

  final ItemCubit? selectedNote;
  final ItemStatus? status;

  @override
  List<Object?> get props => [status, selectedNote];
}
