import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mooc/pages/loading_page.dart';
import 'package:mooc/services/auth_service.dart' as auth_service;

// myPage class which creates a state on call
class Wrapper extends StatefulWidget {
  final StatefulWidget goToPage;
  final bool needsAuthentication;
  const Wrapper(this.goToPage, {Key? key, this.needsAuthentication = false})
      : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<Wrapper> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> callAsyncFetch() async {
    if (auth_service.globalUser.isLoggedIn()) {
      return true;
    }
    // try to log in based on token from localStorage
    await auth_service.globalUser.tryLogin();

    // is the token valid?
    if (auth_service.globalUser.isLoggedIn()) {
      return true;
    }

    // means that no valid login token was found
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.needsAuthentication) {
      return FutureBuilder<bool>(
          future: callAsyncFetch(),
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              bool isLoggedIn = snapshot.data!;
              if (isLoggedIn) {
                return widget.goToPage;
              } else {
                SchedulerBinding.instance?.addPostFrameCallback((_) {
                  Navigator.of(context).pushNamed("/login");
                });
                return const LoadingPage();
              }
            } else {
              return const LoadingPage();
            }
          });
    } else {
      return widget.goToPage;
    }
    /*
    Future<bool> _getData() async {
      print("going");
      // load the application side assets
      //if (!_dataService.isCachedAsset("data/checklists.json")) {}
      print("prompting inpsection saving");
      //_dataUserService.promptUpdateMemoryInspection();
      //await _auth.getSavedToken();
      return true;
      /*
      print("standby to auth");
      if (await _auth.isTokenValid()) {
        print("token's go");
        return true;
      } else {
        print("token's NO go");
        return false;
      }
      */
    }
    */
  }
}
