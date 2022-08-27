part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthStateChanged extends AuthEvent {
  const AuthStateChanged(this.status);

  // the status is the ultimate login result state in the auth repository
  // the login state is just the state of the *login form*
  final AuthStatus status;

  @override
  List<Object> get props => [status];
}

class AuthLogoutRequested extends AuthEvent {}
