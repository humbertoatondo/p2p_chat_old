import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

part 'users_search_event.dart';
part 'users_search_state.dart';

class UsersSearchBloc extends Bloc<UsersSearchEvent, UsersSearchState> {
  UsersSearchBloc() : super(UsersSearchInitial());

  @override
  Stream<UsersSearchState> mapEventToState(
    UsersSearchEvent event,
  ) async* {
    // TODO: implement mapEventToState
    if (event is SearchUsers) {
      if (event.searchTerm.length > 0) {
        yield WaitingResults();
        var body = {
          'searchTerm': event.searchTerm,
        };

        var uri = Uri.http(
          "192.168.1.89:3000",
          "/user/searchUsers",
          body,
        );

        var response = await http.get(uri);

        final mapBody = json.decode(response.body);
        final List<dynamic> usernames = mapBody["usernames"];
        if (usernames.length > 0) {
          yield DisplayingUsers(usernames);
        } else {
          yield DisplayingNoUsersFound();
        }
      } else {
        yield UsersSearchInitial();
      }
    }
  }
}
