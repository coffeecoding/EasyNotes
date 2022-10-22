part of 'selected_note_cubit.dart';

enum SelectedNoteStatus { empty, persisted, newDraft, draft, busy, error }

class SelectedNoteState extends Equatable {
  const SelectedNoteState._(
      {this.status = SelectedNoteStatus.empty, this.selectedNote});

  const SelectedNoteState.empty() : this._();

  const SelectedNoteState.persisted({ItemCubit? note})
      : this._(status: SelectedNoteStatus.persisted, selectedNote: note);

  const SelectedNoteState.newDraft({ItemCubit? note})
      : this._(status: SelectedNoteStatus.newDraft, selectedNote: note);

  const SelectedNoteState.draft({ItemCubit? note})
      : this._(status: SelectedNoteStatus.draft, selectedNote: note);

  const SelectedNoteState.busy({ItemCubit? note})
      : this._(status: SelectedNoteStatus.busy, selectedNote: note);

  const SelectedNoteState.error({ItemCubit? note})
      : this._(status: SelectedNoteStatus.error, selectedNote: note);

  final SelectedNoteStatus status;
  final ItemCubit? selectedNote;

  @override
  List<Object?> get props => [status, selectedNote];
}
