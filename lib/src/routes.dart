import 'package:flutter/material.dart';
import 'package:p2p_chat/src/views/pages/home_page.dart';
import 'package:p2p_chat/src/views/pages/login_page.dart';

class Routes {
  static Route<dynamic> generateRoutes(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => HomePage());
    }
  }
}
