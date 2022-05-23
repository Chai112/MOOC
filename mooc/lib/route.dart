import 'dart:convert';

import 'package:flutter/material.dart';
import 'wrapper.dart';
import 'pages/home.dart';

class RouteGenerator {
  static dynamic _returnToHome(settings) {
    return MaterialPageRoute(
        settings: settings, builder: (context) => Wrapper(HomePage()));
  }

  static Route<dynamic> generateRoute(settings) {
    // Handle '/'
    if (settings.name == '/') {
      return MaterialPageRoute(
          settings: settings, builder: (context) => Wrapper(HomePage()));
      //Wrapper(AuthenticationPage(), needsAuthentication: false));
    }

    if (settings.name == '/dashboard') {
      return MaterialPageRoute(
          settings: settings, builder: (context) => Wrapper(HomePage()));
    }

    var uri = Uri.parse(settings.name);

    // Handle '/incidents/:reportId'
    /*
    if (uri.pathSegments.first == 'incidents' && uri.hasQuery) {
      var reportId = uri.queryParameters["id"];
      if (reportId == null) return _returnToHome(settings);

      // TODO: add a try catch here, also in wrapper.dart to remove Wrapper() from route.dart
      var page = Wrapper(IncidentsReportWrapper(reportId: reportId));
      return MaterialPageRoute(
          settings: settings,
          builder: (context) => page); // this one is actually returned
    }

    */
    return MaterialPageRoute(builder: (context) => Wrapper(HomePage()));
  }
}
