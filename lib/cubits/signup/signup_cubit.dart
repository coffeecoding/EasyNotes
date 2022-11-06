import 'package:bloc/bloc.dart';
import 'package:easynotes/models/user.dart';
import 'package:easynotes/repositories/auth_repository.dart';
import 'package:easynotes/utils/string_util.dart';
import 'package:equatable/equatable.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit({required this.authRepo}) : super(const SignupState());

  final AuthRepository authRepo;

  void handleUsernameChanged(String username) {
    emit(state.copyWith(username: username));
  }

  void handleEmailChanged(String email) {
    emit(state.copyWith(emailAddress: email));
  }

  void handlePasswordChanged(String password) {
    emit(state.copyWith(password: password));
  }

  void handleConfirmedPasswordChanged(String confirmedPassword) {
    emit(state.copyWith(confirmedPassword: confirmedPassword));
  }

  Future<bool> signup() async {
    try {
      emit(state.copyWith(status: SignupStatus.busy));
      User newUser =
          await User.create(state.username, state.emailAddress, state.password);
      bool success = await authRepo.signup(newUser);
      if (!success) {
        // Todo: Specify why no success (e.g. validation error from backend)
        emit(state.copyWith(
            status: SignupStatus.error,
            message:
                'An error occurred. Please verify your internet connection or try again later.'));
        return false;
      }
      emit(state.copyWith(
          status: SignupStatus.success,
          message:
              'Thanks for registering! :) Now log into your account and start noting down your brilliant ideas!'));
      return true;
    } catch (e) {
      emit(state.copyWith(
          status: SignupStatus.error,
          message:
              'An error occurred. Please verify your internet connection or try again later.'));
      return false;
    }
  }

  bool validate() {
    if (state.username.isEmpty) {
      emit(state.copyWith(
          status: SignupStatus.error, message: 'Username is required.'));
      return false;
    }
    if (state.username.length > 63) {
      emit(state.copyWith(
          status: SignupStatus.error, message: 'Username is too long.'));
      return false;
    }
    if (!state.username.isAlphanumeric()) {
      emit(state.copyWith(
          status: SignupStatus.error,
          message: 'Username may only contain letters and numbers.'));
      return false;
    }
    if (state.emailAddress.isEmpty) {
      emit(state.copyWith(
          status: SignupStatus.error, message: 'Email address is required.'));
      return false;
    }
    if (state.emailAddress.length > 767) {
      emit(state.copyWith(
          status: SignupStatus.error, message: 'Email address is too long.'));
      return false;
    }
    if (!state.emailAddress.isValidEmail()) {
      emit(state.copyWith(
          status: SignupStatus.error, message: 'Email address invalid.'));
      return false;
    }
    if (state.password.isEmpty) {
      emit(state.copyWith(
          status: SignupStatus.error, message: 'Password is required.'));
      return false;
    }
    // optional here: strong password check
    if (state.password.length > 255) {
      emit(state.copyWith(
          status: SignupStatus.error, message: 'Password is too long.'));
      return false;
    }
    if (state.confirmedPassword != state.password) {
      emit(state.copyWith(
          status: SignupStatus.error,
          message: 'Confirmed password must match password.'));
      return false;
    }
    return true;
  }
}
