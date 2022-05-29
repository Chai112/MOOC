import 'package:flutter/material.dart';
import 'package:mooc/style/widgets/scholarly_button.dart';
import 'package:mooc/style/widgets/scholarly_text_field.dart';
import 'package:mooc/style/widgets/scholarly_tile.dart';
import 'package:mooc/style/widgets/scholarly_text.dart';

import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:mooc/services/networking_service.dart' as networking_service;

// myPage class which creates a state on call
class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<AuthPage> {
  final _usernameController = ScholarlyTextFieldController();
  final _passwordController = ScholarlyTextFieldController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    setState(() {
      _usernameController.clearError();
      _passwordController.clearError();
    });
    if (username == "") {
      setState(() {
        _usernameController.errorText = "Please enter a username.";
      });
      return;
    }
    if (password == "") {
      setState(() {
        _passwordController.errorText = "Please enter a password.";
      });
      return;
    }
    try {
      await auth_service.AuthUser().login(
        username: username,
        password: password,
      );
    } on networking_service.NetworkingException catch (err) {
      switch (err.message) {
        case "no user exists":
          setState(() {
            _usernameController.errorText = "Username cannot be found.";
          });
          break;
        case "passwords do not match":
          setState(() {
            _passwordController.errorText = "Password is incorrect.";
          });
          break;
        default:
          setState(() {
            _usernameController.errorText =
                "Something went wrong with the server.";
          });
          break;
      }
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 200),
            const SizedBox(
                height: 50,
                child: Image(
                    fit: BoxFit.fill, image: AssetImage('assets/logo.png'))),
            const SizedBox(height: 10),
            const ScholarlyTextH2("Developer Console"),
            const SizedBox(height: 70),
            ScholarlyTile(
                width: 470,
                child: Column(
                  children: [
                    ScholarlyTextField(
                      label: "Username",
                      controller: _usernameController,
                      isPragmaticField: true,
                    ),
                    ScholarlyTextField(
                      label: "Password",
                      controller: _passwordController,
                      isPragmaticField: true,
                      isPasswordField: true,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ScholarlyButton("Login",
                            onPressed: login, invertedColor: true),
                        ScholarlyButton(
                          "Create an Account",
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                        ),
                      ],
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
