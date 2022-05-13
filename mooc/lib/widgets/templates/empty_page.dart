import 'package:flutter/material.dart';

// myPage class which creates a state on call
class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<MyPage> {
  // main build function
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page"),
      ),
      body: Container(),
    );
  }
}
