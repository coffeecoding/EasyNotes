import 'package:bloc/bloc.dart';
import 'package:easynotes/repositories/auth_repository.dart';
import 'package:easynotes/repositories/preference_repository.dart';
import 'package:equatable/equatable.dart';

part 'preference_state.dart';

class PreferenceCubit extends Cubit<PreferenceState> {
  PreferenceCubit({required this.prefsRepo, required this.authRepo})
      : super(const PreferenceState.init()) {
    _initialize();
  }

  final PreferenceRepository prefsRepo;
  final AuthRepository authRepo;

  Future<String> get email async => (await prefsRepo.loggedInUser)!.email;
  Future<String> get password async => (await prefsRepo.password)!;

  Future<void> _initialize() async {
    bool enableSync = await prefsRepo.enableSync;
    bool useDarkMode = await prefsRepo.useDarkMode;
    emit(PreferenceState.copyWith(
        prev: state, enableSync: enableSync, useDarkMode: useDarkMode));
  }

  void handleChanged(
          {bool? sync,
          bool? darkMode,
          bool? editingEmail,
          bool? editingPassword}) =>
      emit(PreferenceState.copyWith(
          prev: state,
          enableSync: sync,
          useDarkMode: darkMode,
          isEditingEmail: editingEmail,
          isEditingPassword: editingPassword));

  void updateSync(bool newValue) {
    //
  }

  void updateUseDarkMode(bool newValue) {
    //
  }

  Future<void> updateUser({String? newPassword, String? newEmail}) async {
    try {
      bool success = await authRepo.updateUser(
          newPassword: newPassword, newEmail: newEmail);
      if (success) {
        emit(PreferenceState.copyWith(
            prev: state,
            isEditingEmail: false,
            isEditingPassword: false,
            message: 'Successfully updated!'));
      } else {
        emit(PreferenceState.copyWith(
            prev: state, message: 'Something went wrong ...'));
      }
    } catch (e) {
      print('Failed to update user: $e');
      emit(PreferenceState.copyWith(
          prev: state, message: 'Something went wrong ...'));
    }
  }
}
