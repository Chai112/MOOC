import 'package:flutter/material.dart';
import 'wrapper.dart';
import 'pages/home.dart';
import 'pages/auth.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(settings) {
    // Handle '/'
    if (settings.name == '/') {
      return MaterialPageRoute(
          settings: settings, builder: (context) => Wrapper(const AuthPage()));
      //Wrapper(AuthenticationPage(), needsAuthentication: false));
    }

    if (settings.name == '/dashboard') {
      return MaterialPageRoute(
          settings: settings, builder: (context) => Wrapper(const HomePage()));
    }

    //var uri = Uri.parse(settings.name);

    // Handle '/incidents/:reportId'
    /*
    if (uri.pathSegments.first == 'incidents' && uri.hasQuery) {
      var reportId = uri.queryParameters["id"];
      if (reportId == null) return _returnToHome(settings);

      // add a try catch here, also in wrapper.dart to remove Wrapper() from route.dart
      var page = Wrapper(IncidentsReportWrapper(reportId: reportId));
      return MaterialPageRoute(
          settings: settings,
          builder: (context) => page); // this one is actually returned
    }

    */
    return MaterialPageRoute(builder: (context) => Wrapper(const HomePage()));
  }
}
