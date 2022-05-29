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
  String? _usernameFieldErrorText;
  String? _passwordFieldErrorText;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return Scaffold(
      /*
      appBar: AppBar(
        title: Container(
            height: 30,
            child:
                Image(fit: BoxFit.fill, image: AssetImage('assets/logo.png'))),
      ),
      */
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 200),
            const SizedBox(
                height: 70,
                child: Image(
                    fit: BoxFit.fill, image: AssetImage('assets/logo.png'))),
            const SizedBox(height: 10),
            const ScholarlyTextH2("Developer Console"),
            const SizedBox(height: 70),
            ScholarlyTile(
                width: 470,
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    ScholarlyTextField(
                      label: "Username",
                      errorText: _usernameFieldErrorText,
                    ),
                    ScholarlyTextField(
                      label: "Password",
                      errorText: _passwordFieldErrorText,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ScholarlyButton("Login", onPressed: () async {
                          try {
                            await auth_service.AuthUser().login(
                              username: "a",
                              password: "b",
                            );
                          } on networking_service
                              .NetworkingException catch (err) {
                            switch (err.message) {
                              case "no user exists":
                                setState(() {
                                  _usernameFieldErrorText = "No user exists.";
                                });
                                break;
                              case "passwords do not match":
                                setState(() {
                                  _passwordFieldErrorText = "No user exists.";
                                });
                                break;
                              default:
                                setState(() {
                                  _usernameFieldErrorText =
                                      "Something went wrong with the server.";
                                });
                                break;
                            }
                          }
                        }, invertedColor: true),
                        ScholarlyButton(
                          "Create an Account",
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
