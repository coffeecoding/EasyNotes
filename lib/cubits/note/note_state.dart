part of 'note_cubit.dart';

abstract class NoteState extends Equatable {
  const NoteState({required this.note});

  final Item? note;

  @override
  List<Object?> get props => [note];
}

class DefaultNoteState extends NoteState {
  const DefaultNoteState({Item? note}) : super(note: note);
}
