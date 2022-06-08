import 'package:flutter/material.dart';

// myPage class which creates a state on call
class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<LoadingPage> {
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
    return const Scaffold(
        body: Center(
      child: CircularProgressIndicator(),
    ));
  }
}
