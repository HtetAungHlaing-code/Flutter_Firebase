import 'package:flutter/material.dart';
import 'package:flutter_firebase/Auth/Services/authentication.dart';
import 'package:flutter_firebase/Auth/UI/root_page.dart';
import 'package:flutter_firebase/Auth/login_signup_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RootPage(auth: Auth(),),
    );
  }
}
