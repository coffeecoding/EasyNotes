part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState._(
      {this.status = AuthStatus.unauthenticated, this.user = User.empty});

  const AuthState.unauthenticated() : this._();

  factory AuthState.unauth() => AuthState.unauthenticated();

  const AuthState.authenticated(User user)
      : this._(status: AuthStatus.authenticated, user: user);

  final AuthStatus status;
  final User user;

  @override
  List<Object> get props => [];
}
