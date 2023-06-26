import 'package:flutter/material.dart';
import 'package:flutter_todo_list/dialogs/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle roundButtonStyle = ElevatedButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cписок дел'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Добро пожаловать в приложение "Список дел"!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
            const Text(
              'Для начала работы авторизуйтесь с помощью Google',
              textAlign: TextAlign.center,
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
            ElevatedButton.icon(
              onPressed: () {
                final provider =
                    Provider.of<GoogleSignInProvider>(context, listen: false);
                provider.googleLogin();
              },
              icon: const FaIcon(FontAwesomeIcons.google),
              label: const Text('Войти через Google'),
              style: roundButtonStyle,
            ),
          ],
        ),
      ),
    );
  }
}
