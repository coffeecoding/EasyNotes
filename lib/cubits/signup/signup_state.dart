part of 'signup_cubit.dart';

enum SignupStatus { initial, busy, error, success }

class SignupState extends Equatable {
  const SignupState({
    this.status = SignupStatus.initial,
    this.username = '',
    this.emailAddress = '',
    this.password = '',
    this.confirmedPassword = '',
    this.message = '',
  });

  SignupState copyWith({
    SignupStatus? status,
    String? username,
    String? emailAddress,
    String? password,
    String? confirmedPassword,
    String? message,
  }) =>
      SignupState(
          status: status ?? this.status,
          username: username ?? this.username,
          emailAddress: emailAddress ?? this.emailAddress,
          password: password ?? this.password,
          confirmedPassword: confirmedPassword ?? this.confirmedPassword,
          message: message ?? this.message);

  final SignupStatus status;
  final String username;
  final String emailAddress;
  final String password;
  final String confirmedPassword;
  final String message;

  @override
  List<Object> get props =>
      [status, username, emailAddress, password, confirmedPassword, message];
}
