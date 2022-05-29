import 'package:flutter/material.dart';
import 'package:mooc/style/widgets/scholarly_button.dart';
import 'package:mooc/style/widgets/scholarly_divider.dart';
import 'package:mooc/style/widgets/scholarly_text_field.dart';
import 'package:mooc/style/widgets/scholarly_tile.dart';
import 'package:mooc/style/widgets/scholarly_text.dart';

import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:mooc/services/networking_service.dart' as networking_service;

// myPage class which creates a state on call
class AuthRegisterPage extends StatefulWidget {
  const AuthRegisterPage({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<AuthRegisterPage> {
  final _usernameController = ScholarlyTextFieldController();
  final _passwordController = ScholarlyTextFieldController();
  final _emailController = ScholarlyTextFieldController();
  final _firstnameController = ScholarlyTextFieldController();
  final _lastnameController = ScholarlyTextFieldController();

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

  void register() async {}

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 90),
            const SizedBox(
                height: 30,
                child: Image(
                    fit: BoxFit.fill, image: AssetImage('assets/logo.png'))),
            const SizedBox(height: 10),
            const ScholarlyTextH2("Developer Console"),
            const SizedBox(height: 50),
            ScholarlyTile(
                width: 470,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/');
                        },
                        icon: const Icon(Icons.arrow_back_rounded)),
                    const SizedBox(height: 20),
                    const ScholarlyTextH3("Login Information"),
                    const SizedBox(height: 20),
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
                    const ScholarlyDivider(),
                    const ScholarlyTextH3("Contact Information"),
                    const SizedBox(height: 20),
                    ScholarlyTextField(
                      label: "Email",
                      controller: _emailController,
                      isPragmaticField: true,
                      isPasswordField: true,
                    ),
                    ScholarlyTextField(
                      label: "First Name",
                      controller: _firstnameController,
                      isPragmaticField: true,
                      isPasswordField: true,
                    ),
                    ScholarlyTextField(
                      label: "Last Name",
                      controller: _lastnameController,
                      isPragmaticField: true,
                      isPasswordField: true,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ScholarlyButton("Register",
                            onPressed: register, invertedColor: true),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
