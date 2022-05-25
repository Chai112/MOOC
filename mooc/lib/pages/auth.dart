import 'package:flutter/material.dart';
import 'package:mooc/style/widgets/scholarly_text_field.dart';
import 'package:mooc/style/widgets/scholarly_tile.dart';

// myPage class which creates a state on call
class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<AuthPage> {
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
            const SizedBox(height: 100),
            const ScholarlyTile(
                width: 500,
                height: 300,
                child: ScholarlyTextField(
                  label: "username",
                ))
          ],
        ),
      ),
    );
  }
}
