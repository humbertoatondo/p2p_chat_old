part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent([Object list]);

  @override
  List<Object> get props => [];
}

class ShowChats extends HomeEvent {}

class SearchUsers extends HomeEvent {}
