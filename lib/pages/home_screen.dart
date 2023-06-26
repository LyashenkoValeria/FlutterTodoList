import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_list/pages/categories_screen.dart';
import 'package:flutter_todo_list/pages/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text('Пожалуйста, подождите...'));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Упс! Что-то пошло не так'));
          } else if (snapshot.hasData) {
            return const CategoriesScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
