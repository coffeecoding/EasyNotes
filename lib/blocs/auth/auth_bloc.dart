import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:easynotes/models/user.dart';
import 'package:easynotes/repositories/auth_repository.dart';
import 'package:easynotes/repositories/preference_repository.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
      {required AuthRepository authRepository,
      required PreferenceRepository preferenceRepository})
      : _authRepository = authRepository,
        _preferenceRepository = preferenceRepository,
        super(const AuthState.unauthenticated()) {
    on<AuthStateChanged>(_onAuthStatusChanged);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    _authStatusSubscription = _authRepository.status.listen(
      (status) => add(AuthStateChanged(status)),
    );
  }

  final AuthRepository _authRepository;
  final PreferenceRepository _preferenceRepository;
  late StreamSubscription<AuthStatus> _authStatusSubscription;

  @override
  Future<void> close() {
    _authStatusSubscription.cancel();
    _authRepository.dispose();
    return super.close();
  }

  Future<void> _onAuthStatusChanged(
      AuthStateChanged event, Emitter<AuthState> emit) async {
    switch (event.status) {
      case AuthStatus.unauthenticated:
        return emit(const AuthState.unauthenticated());
      case AuthStatus.authenticated:
        // user should be saved in preferences => get it from prefsrepository
        final user = await _preferenceRepository.loggedInUser;
        return emit(user != null
            ? AuthState.authenticated(user)
            : const AuthState.unauthenticated());
    }
  }

  void _onAuthLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    _authRepository.logout();
  }
}
