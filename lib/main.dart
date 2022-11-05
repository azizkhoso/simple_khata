import 'package:flutter/material.dart';
import 'package:simple_khata/login_page.dart';
import 'package:simple_khata/register_page.dart';
import 'package:simple_khata/user_khata_page.dart';
import './home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Khata',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'Simple Khata'),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/user-khata': (context) => const UserKhata(),
      },
    );
  }
}
