import 'package:flutter/material.dart';

// myPage class which creates a state on call
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<HomePage> {
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
        title: const Text("Chai MOOC"),
      ),
      body: Container(),
    );
  }
}
