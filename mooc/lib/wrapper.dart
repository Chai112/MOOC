import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  var goToPage;
  bool needsAuthentication;
  Wrapper(var goToPage, {this.needsAuthentication = false}) {
    this.goToPage = goToPage;
  }

  @override
  Widget build(BuildContext context) {
    return goToPage;
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
  }
}
