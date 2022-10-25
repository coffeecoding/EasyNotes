part of 'selected_note_cubit.dart';

class SelectedNoteState extends Equatable {
  const SelectedNoteState._({this.selectedNote, this.status});

  const SelectedNoteState.empty() : this._();

  const SelectedNoteState.persisted(ItemVM note)
      : this._(status: ItemVMStatus.persisted, selectedNote: note);

  const SelectedNoteState.newDraft(ItemVM note)
      : this._(status: ItemVMStatus.newDraft, selectedNote: note);

  const SelectedNoteState.draft(ItemVM note)
      : this._(status: ItemVMStatus.draft, selectedNote: note);

  const SelectedNoteState.busy(ItemVM note)
      : this._(status: ItemVMStatus.busy, selectedNote: note);

  const SelectedNoteState.error(ItemVM note)
      : this._(status: ItemVMStatus.error, selectedNote: note);

  final ItemVM? selectedNote;
  final ItemVMStatus? status;

  @override
  List<Object?> get props => [status, selectedNote];
}
