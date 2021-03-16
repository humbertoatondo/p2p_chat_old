part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginWaitingForResponse extends LoginState {}

class SuccessfulLogin extends LoginState {}

class UnsuccessfulLogin extends LoginState {}
