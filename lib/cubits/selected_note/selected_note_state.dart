part of 'selected_note_cubit.dart';

enum SelectedNoteStatus { empty, persisted, newDraft, draft, busy, error }

class SelectedNoteState extends Equatable {
  const SelectedNoteState._(
      {this.status = SelectedNoteStatus.empty, this.selectedNote});

  const SelectedNoteState.empty() : this._();

  const SelectedNoteState.changed(
      {required SelectedNoteStatus status, ItemCubit? note})
      : this._(status: status, selectedNote: note);

  final SelectedNoteStatus status;
  final ItemCubit? selectedNote;

  @override
  List<Object?> get props => [status, selectedNote];
}
