import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:p2p_chat/src/business_logic/blocs/users_search_bloc/users_search_bloc.dart';

class UsersSearchScreen extends StatefulWidget {
  UsersSearchScreen({
    Key key,
    this.searchUserController,
  }) : super(key: key);

  final TextEditingController searchUserController;

  @override
  _UsersSearchScreenState createState() => _UsersSearchScreenState();
}

class _UsersSearchScreenState extends State<UsersSearchScreen> {
  final usersSearchBloc = UsersSearchBloc();

  List<Widget> getUserCells(List<dynamic> users) {
    List<Widget> cells = [];
    users.forEach((user) {
      cells.add(UserListViewCell());
    });
    return cells;
  }

  @override
  void initState() {
    super.initState();
    widget.searchUserController.addListener(() {
      var searchTerm = widget.searchUserController.text;
      usersSearchBloc.add(SearchUsers(searchTerm));
    });
  }

  @override
  void dispose() {
    usersSearchBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      cubit: usersSearchBloc,
      builder: (context, state) {
        if (state is DisplayingUsers) {
          return ListView(
            children: getUserCells(state.users),
          );
        }
        return Container(
          color: Colors.amber,
        );
      },
    );
  }
}

class UserListViewCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: 60,
        margin: EdgeInsets.all(8),
        color: Colors.purple);
  }
}
