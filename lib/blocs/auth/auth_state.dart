part of 'auth_bloc.dart';

// Note on single class state with named constructors vs multiple state sub-
// classes: Single class is the new approach and its advantages are explained
// here, by the man himself: https://github.com/felangel/bloc/issues/1726

enum AuthStatus { authenticated, unauthenticated, error, waiting }

class AuthState extends Equatable {
  const AuthState._(
      {this.status = AuthStatus.unauthenticated, this.user = User.empty});

  const AuthState.unauthenticated() : this._();

  const AuthState.authenticated(User user)
      : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.error() : this._(status: AuthStatus.error);

  const AuthState.waiting() : this._(status: AuthStatus.waiting);

  final AuthStatus status;
  final User user;

  @override
  List<Object> get props => [status, user];
}

/*
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

abstract class AuthStateWithData extends AuthState {
  const AuthStateWithData({required this.user});

  final User user;

  @override
  List<Object> get props => [user];
}

class UnauthenticatedState extends AuthState {}

class AuthenticatingState extends AuthStateWithData {
  const AuthenticatingState({required User user}) : super(user: user);
}

class AuthenticatedState extends AuthStateWithData {
  const AuthenticatedState({required User user}) : super(user: user);
}

class AuthErrorState extends AuthStateWithData {
  const AuthErrorState({required User user}) : super(user: user);
}

*/
