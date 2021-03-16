import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:p2p_chat/src/business_logic/blocs/login_bloc/login_bloc.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginBloc = new LoginBloc();

  final _userTextEditingController = new TextEditingController();
  final _passwordTextEditingController = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _loginBloc.close();
    _userTextEditingController.dispose();
    _passwordTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(minWidth: 250, maxWidth: 350),
            // padding: EdgeInsets.only(left: 24, right: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _userTextEditingController,
                  obscureText: false,
                  decoration: InputDecoration(
                    labelText: "User",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                TextField(
                  controller: _passwordTextEditingController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                BlocListener(
                  cubit: _loginBloc,
                  listener: (context, state) {
                    if (state is SuccessfulLogin) {
                      Navigator.of(context).pushNamed('/home');
                    }
                  },
                  child: ElevatedButton(
                    onPressed: () {
                      _loginBloc.add(
                        SendUserData(
                          _userTextEditingController.text,
                          _passwordTextEditingController.text,
                        ),
                      );
                    },
                    child: Text("Login"),
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.resolveWith(
                        (states) => Size(double.infinity, 0),
                      ),
                      padding: MaterialStateProperty.resolveWith(
                        (states) => EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
