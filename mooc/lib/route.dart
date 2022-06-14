import 'package:flutter/material.dart';
import 'package:mooc/wrapper.dart';
import 'package:mooc/pages/home_page.dart';
import 'package:mooc/pages/auth_page.dart';
import 'package:mooc/pages/auth_register_page.dart';
import 'package:mooc/pages/organization_page.dart';
import 'package:mooc/pages/organization_register_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(settings) {
    // Handle '/'
    if (settings.name == '/') {
      return MaterialPageRoute(
          settings: settings,
          builder: (context) => const Wrapper(
                OrganizationPage(),
                needsAuthentication: true,
              ));
    }

    if (settings.name == '/login') {
      return MaterialPageRoute(
          settings: settings, builder: (context) => const Wrapper(AuthPage()));
    }

    if (settings.name == '/register') {
      return MaterialPageRoute(
          settings: settings,
          builder: (context) => const Wrapper(AuthRegisterPage()));
    }

    if (settings.name == '/organization-register') {
      return MaterialPageRoute(
          settings: settings,
          builder: (context) => const Wrapper(
                OrganizationRegisterPage(),
                needsAuthentication: true,
              ));
    }

    if (settings.name == '/dashboard') {
      return MaterialPageRoute(
          settings: settings, builder: (context) => const Wrapper(HomePage()));
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
    return MaterialPageRoute(builder: (context) => const Wrapper(HomePage()));
  }
}
