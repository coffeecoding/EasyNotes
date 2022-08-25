import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:easynotes/models/user.dart';
import 'package:easynotes/repositories/auth_repository.dart';
import 'package:easynotes/repositories/user_repository.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
      {required AuthRepository authRepository,
      required UserRepository userRepository})
      : _authRepository = authRepository,
        _userRepository = userRepository,
        super(const AuthState.unauthenticated()) {
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    _authStatusSubscription = _authRepository.status
        .listen((status) => add(AuthStatusChanged(status)));
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  late StreamSubscription<AuthStatus> _authStatusSubscription;

  @override
  Future<void> close() {
    _authStatusSubscription.cancel();
    _authRepository.dispose();
    return super.close();
  }

  Future<void> _onAuthStatusChanged(
      AuthStatusChanged event, Emitter<AuthState> emit) async {
    switch (event.status) {
      case AuthStatus.unauthenticated:
        return emit(const AuthState.unauthenticated());
      case AuthStatus.authenticated:
        final user = await _tryGetUser();
        return emit(user != null
            ? AuthState.authenticated(user)
            : const AuthState.unauthenticated());
    }
  }

  void _onAuthLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    _authRepository.logout();
  }

  Future<User?> _tryGetUser() async {
    try {
      final user = await _userRepository.getUser();
      return user;
    } catch (_) {
      return null;
    }
  }
}
