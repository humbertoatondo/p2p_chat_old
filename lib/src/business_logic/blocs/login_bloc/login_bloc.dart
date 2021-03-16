import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is SendUserData) {
      yield LoginWaitingForResponse();
      var body = json.encode({
        'name': event.username,
        'password': event.password,
      });

      var response = await http.post(
        Uri.parse("http://192.168.1.89:3000/user/login"),
        body: body,
      );

      var logger = Logger(
        printer: PrettyPrinter(
            methodCount: 0, // number of method calls to be displayed
            errorMethodCount:
                8, // number of method calls if stacktrace is provided
            lineLength: 60, // width of the output
            colors: true, // Colorful log messages
            printEmojis: true, // Print an emoji for each log message
            printTime: true // Should each log print contain a timestamp
            ),
      );

      logger.i("Login response: " + response.statusCode.toString());

      if (response.statusCode == HttpStatus.ok) {
        yield SuccessfulLogin();
      } else {
        yield UnsuccessfulLogin();
        yield LoginInitial();
      }
    }
  }
}
