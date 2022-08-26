import 'package:bloc/bloc.dart';
import 'package:easynotes/models/user.dart';
import 'package:easynotes/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(LoginState.initial());

  final AuthRepository _authRepository;

  Future<void> loginWithCredentials(String username, String password) async {
    if (state.status == LoginStatus.submitting) return;
    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      _authRepository.login(username: username, password: password);
    } on Exception {}
  }
}
