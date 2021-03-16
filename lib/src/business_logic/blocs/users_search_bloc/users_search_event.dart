part of 'users_search_bloc.dart';

abstract class UsersSearchEvent extends Equatable {
  const UsersSearchEvent([Object list]);

  @override
  List<Object> get props => [];
}

class SearchUsers extends UsersSearchEvent {
  final String searchTerm;

  SearchUsers(this.searchTerm) : super([searchTerm]);
}
