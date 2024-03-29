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

  Future<void> updateSync(bool newValue) async {
    await prefsRepo.setEnableSync(newValue);
    emit(PreferenceState.copyWith(prev: state, enableSync: newValue));
  }

  Future<void> updateUseDarkMode(bool newValue) async {
    await prefsRepo.setUseDarkMode(newValue);
    emit(PreferenceState.copyWith(prev: state, useDarkMode: newValue));
  }

  Future<bool> updateUser({String? newPassword, String? newEmail}) async {
    try {
      emit(PreferenceState.copyWith(prev: state));
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
      return success;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to update user: $e');
      emit(PreferenceState.copyWith(
          prev: state, message: 'Something went wrong ...'));
      return false;
    }
  }
}
