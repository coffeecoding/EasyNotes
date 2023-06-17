// ignore_for_file: avoid_print

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:easynotes/cubits/cubits.dart';
import 'package:easynotes/models/item.dart';
import 'package:easynotes/models/user.dart';
import 'package:easynotes/repositories/auth_repository.dart';
import 'package:easynotes/repositories/item_repository.dart';
import 'package:easynotes/repositories/preference_repository.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
      {required AuthRepository authRepository,
      required PreferenceRepository preferenceRepository,
      required ItemRepository itemRepository})
      : _authRepository = authRepository,
        _prefs = preferenceRepository,
        _itemRepo = itemRepository,
        super(const AuthState.unauthenticated()) {
    on<AuthStateChanged>(_onAuthStatusChanged);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
  }

  final AuthRepository _authRepository;
  final PreferenceRepository _prefs;
  final ItemRepository _itemRepo;
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
      MapEntry<String, List<Item>> result = await _authRepository.login(
          username: event.username, password: event.password);
      if (result.key.isNotEmpty) throw Exception(result.key);
      await _itemRepo.setItems(result.value);
      User user = (await _prefs.loggedInUser)!;
      return emit(AuthState.authenticated(user));
    } catch (e) {
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
