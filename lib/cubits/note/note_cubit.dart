import 'package:bloc/bloc.dart';
import 'package:easynotes/models/item.dart';
import 'package:equatable/equatable.dart';

part 'note_state.dart';

class NoteCubit extends Cubit<NoteState> {
  NoteCubit({Item? note}) : super(DefaultNoteState(note: note));
}
