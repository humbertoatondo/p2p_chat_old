part of 'users_search_bloc.dart';

abstract class UsersSearchState extends Equatable {
  const UsersSearchState([Object list]);

  @override
  List<Object> get props => [];
}

class UsersSearchInitial extends UsersSearchState {}

class WaitingResults extends UsersSearchState {}

class DisplayingUsers extends UsersSearchState {
  final List<dynamic> users;
  DisplayingUsers(this.users) : super([users]);
}

class DisplayingNoUsersFound extends UsersSearchState {}
