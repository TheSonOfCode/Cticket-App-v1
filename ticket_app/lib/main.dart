import 'package:flutter/material.dart';
import 'package:ticket_app/screens/forgot_password_screen.dart';
import 'package:ticket_app/screens/formulaire_screen.dart';
import 'package:ticket_app/screens/list_register_screen.dart';
import 'package:ticket_app/screens/login_screen.dart';
import 'package:ticket_app/screens/signup_screen.dart';
import 'package:ticket_app/services/auth_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService authService = AuthService();

  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App ticket',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: authService.estConnecte(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.data == true) {
            return const FormulaireScreen();
          }
          return LoginScreen();
        },
      ),
      routes: {
        '/registration': (context) => const FormulaireScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/list': (context) => ListScreen(),
      },
    );
  }
}
