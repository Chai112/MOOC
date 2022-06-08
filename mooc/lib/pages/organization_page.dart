import 'package:flutter/material.dart';
import 'package:mooc/services/auth_service.dart' as auth_service;

// myPage class which creates a state on call
class OrganizationPage extends StatefulWidget {
  const OrganizationPage({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<OrganizationPage> {
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
      appBar: AppBar(
        title: Container(
            height: 20,
            child:
                Image(fit: BoxFit.fill, image: AssetImage('assets/logo.png'))),
      ),
      body: Row(
        children: [
          SizedBox(
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Container(
                  decoration: BoxDecoration(color: Colors.white),
                )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 200),
              Text("Welcome back, "),
              Container(),
            ],
          ),
        ],
      ),
    );
  }
}
