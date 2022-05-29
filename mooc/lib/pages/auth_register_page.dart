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
  final _retypePasswordController = ScholarlyTextFieldController();
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

  void register() async {
    setState(() {
      _usernameController.clearError();
      _passwordController.clearError();
      _retypePasswordController.clearError();
      _emailController.clearError();
      _firstnameController.clearError();
      _lastnameController.clearError();
    });
    if (_usernameController.text == "") {
      setState(() {
        _usernameController.errorText = "Please enter a username.";
      });
      return;
    }
    if (_passwordController.text == "") {
      setState(() {
        _passwordController.errorText = "Please enter a password.";
      });
      return;
    }
    if (_retypePasswordController.text == "") {
      setState(() {
        _retypePasswordController.errorText =
            "Please retype the same password as above.";
      });
      return;
    }
    if (_passwordController.text != _retypePasswordController.text) {
      setState(() {
        _retypePasswordController.errorText =
            "This does not match the password above.";
      });
      return;
    }
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_emailController.text);
    if (_emailController.text != "" && !emailValid) {
      setState(() {
        _emailController.errorText = "This email is not valid";
      });
      return;
    }
    try {
      await auth_service.AuthUser().register(
        username: _usernameController.text,
        password: _passwordController.text,
        email: _emailController.text,
        firstname: _firstnameController.text,
        lastname: _firstnameController.text,
      );
    } on networking_service.NetworkingException catch (err) {
      switch (err.message) {
        case "user already exists":
          setState(() {
            _usernameController.errorText =
                "Username already exists - please choose another one.";
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
            const SizedBox(height: 60),
            const SizedBox(
                height: 30,
                child: Image(
                    fit: BoxFit.fill, image: AssetImage('assets/logo.png'))),
            const SizedBox(height: 10),
            const ScholarlyTextH2("Developer Console"),
            const SizedBox(height: 30),
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
                    const SizedBox(height: 5),
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
                    ScholarlyTextField(
                      label: "Retype Password",
                      controller: _retypePasswordController,
                      isPragmaticField: true,
                      isPasswordField: true,
                    ),
                    const ScholarlyDivider(),
                    const ScholarlyTextH3("Contact Information",
                        bracketText: "(*Optional)"),
                    const SizedBox(height: 20),
                    ScholarlyTextField(
                      label: "Email*",
                      controller: _emailController,
                      isPragmaticField: true,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ScholarlyTextField(
                            label: "First Name*",
                            controller: _firstnameController,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ScholarlyTextField(
                            label: "Last Name*",
                            controller: _lastnameController,
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: ScholarlyButton("Register",
                          onPressed: register, invertedColor: true),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
