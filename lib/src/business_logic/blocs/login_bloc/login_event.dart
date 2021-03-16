part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent([Object list]);

  @override
  List<Object> get props => [];
}

class SendUserData extends LoginEvent {
  final String username;
  final String password;
  SendUserData(this.username, this.password) : super([username, password]);
}
