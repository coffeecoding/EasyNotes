import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'preference_state.dart';

class PreferenceCubit extends Cubit<PreferenceState> {
  PreferenceCubit() : super(PreferenceInitial());
}
