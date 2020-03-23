import 'package:fliprkanban/screens/boards_page.dart';
import 'package:fliprkanban/screens/forgot_password.dart';
import 'package:fliprkanban/screens/login_screen.dart';
import 'package:fliprkanban/screens/todo_page.dart';
import 'package:flutter/material.dart';

import 'screens//registration_screen.dart';
import 'screens//welcome_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kanbello',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Colors.greenAccent,
      ),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        BoardsPage.id: (context) => BoardsPage(),
        TodoPage.id: (context) => TodoPage(),
        ForgotPassword.id: (context) => ForgotPassword(),
      },
    );
  }
}
