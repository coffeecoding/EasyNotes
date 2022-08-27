part of 'login_cubit.dart';

enum LoginStatus { initial, submitting, success, failure }

class LoginState extends Equatable {
  const LoginState({this.status = LoginStatus.initial, this.user});

  final LoginStatus status;
  final User? user;

  LoginState copyWith(
      {LoginStatus? status = LoginStatus.initial,
      String? username = '',
      String? password = '',
      User? user}) {
    return LoginState(status: status ?? this.status, user: user ?? this.user);
  }

  factory LoginState.initial() {
    return const LoginState(status: LoginStatus.initial, user: null);
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [status, user];
}
