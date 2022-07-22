import 'package:flutter/material.dart';

// myPage class which creates a state on call
class MyPage extends StatefulWidget {
  final int x;
  const MyPage({Key? key, required this.x}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

// myPage state
class _MyPageState extends State<MyPage> {
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
    int x2 = widget.x * 2;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page"),
      ),
      body: Container(),
    );
  }
}
