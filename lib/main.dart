import 'package:flutter/material.dart';
import 'package:flutter_todo_list/dialogs/google_sign_in.dart';
import 'package:flutter_todo_list/pages/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void initFirebase() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

void main() {
  initFirebase();
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => GoogleSignInProvider(),
        child: MaterialApp(
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFF183634),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF183634),
            ),
          ),
          home: const HomeScreen(),
        ),
      );
}
