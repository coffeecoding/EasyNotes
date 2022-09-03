import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:easynotes/cubits/cubit/topics_cubit.dart';
import 'package:easynotes/models/sample_data.dart';
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
    on<AuthLoginRequested>(_onAuthLoginRequested);
  }

  final AuthRepository _authRepository;
  final PreferenceRepository _preferenceRepository;
  late StreamSubscription<AuthStatus> _authStatusSubscription;

  @override
  Future<void> close() {
    _authStatusSubscription.cancel();
    return super.close();
  }

  Future<void> _onAuthStatusChanged(
      AuthStateChanged event, Emitter<AuthState> emit) async {
    switch (event.status) {
      case AuthStatus.unauthenticated:
        return emit(const AuthState.unauthenticated());
      case AuthStatus.authenticated:
        // user should have been already saved in preferences
        // => get it from prefsrepository
        return emit(const AuthState.authenticated(User.empty));
      case AuthStatus.error:
        return emit(const AuthState.error());
      case AuthStatus.waiting:
        return emit(const AuthState.waiting());
    }
  }

  Future<void> _onAuthLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    try {
      emit(const AuthState.waiting());
      await _authRepository.login(
          username: event.username, password: event.password);
      // user should have been already saved in preferences
      // => get it from prefsrepository
      event.topicsCubit.fetchTopics();
      return emit(AuthState.authenticated(SampleData.sampleUser));
    } on Exception catch (e) {
      print(e);
      emit(const AuthState.error());
    }
  }

  void _onAuthLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    // Todo: try, catch
    _authRepository.logout();
  }
}
