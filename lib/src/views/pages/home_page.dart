import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:p2p_chat/src/business_logic/blocs/home_bloc/home_bloc.dart';
import 'package:p2p_chat/src/views/screens/chat_screen.dart';
import 'package:p2p_chat/src/views/screens/users_search_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _homeBloc = HomeBloc();

  final _searchUserTextController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _homeBloc.add(SearchUsers());
      } else {
        _homeBloc.add(ShowChats());
      }
    });
  }

  @override
  void dispose() {
    _homeBloc.close();
    _focusNode.dispose();
    _searchUserTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Chats"),
          bottom: PreferredSize(
            child: Container(
              height: 36,
              margin: EdgeInsets.all(12),
              child: TextField(
                controller: _searchUserTextController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: "Search users",
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.blue[800],
                  contentPadding: EdgeInsets.only(left: 8, right: 8),
                ),
              ),
            ),
            preferredSize: Size.fromHeight(kToolbarHeight),
          ),
        ),
        body: BlocBuilder(
          cubit: _homeBloc,
          builder: (context, state) {
            if (state is SearchingUsers) {
              return UsersSearchScreen(
                searchUserController: _searchUserTextController,
              );
            }
            return ChatScreen();
          },
        ));
  }
}
