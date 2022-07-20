import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mooc/wrapper.dart';
import 'package:mooc/pages/home_page.dart';
import 'package:mooc/pages/auth_page.dart';
import 'package:mooc/pages/auth_register_page.dart';
import 'package:mooc/pages/course/course_page.dart';
import 'package:mooc/pages/organization_page.dart';
import 'package:mooc/pages/organization_register_page.dart';

import 'package:mooc/services/error_service.dart' as error_service;
import 'package:mooc/services/networking_service.dart' as networking_service;
import 'package:mooc/services/course_service.dart' as course_service;

class RouteGenerator {
  static Route<dynamic> generateRoute(settings) {
    Uri uri = Uri.parse(settings.name);

    // Handle '/'
    if (settings.name == '/') {
      return MaterialPageRoute(
          settings: settings,
          builder: (context) => const Wrapper(
                HomePage(),
                needsAuthentication: true,
              ));
    }

    if (uri.pathSegments.first == 'login') {
      return MaterialPageRoute(
          settings: settings, builder: (context) => const Wrapper(AuthPage()));
    }

    if (uri.pathSegments.first == 'register') {
      return MaterialPageRoute(
          settings: settings,
          builder: (context) => const Wrapper(AuthRegisterPage()));
    }

    if (uri.pathSegments.first == 'organization') {
      // TODO: needs wrapper to confirm user is authenticated
      String? organizationIdStr = uri.queryParameters["id"];
      int organizationId;

      bool isQueryProvided = organizationIdStr != null;
      if (isQueryProvided) {
        organizationId = int.parse(organizationIdStr);
      } else {
        return MaterialPageRoute(
            settings: settings,
            builder: (context) => ErrorPage(
                error: networking_service.NetworkingException("invalid URL",
                    description: "a query was expected but not provided")));
      }

      return MaterialPageRoute(
          settings: settings,
          builder: (context) => Wrapper(
                OrganizationPage(organizationId: organizationId),
                needsAuthentication: true,
              ));
    }

    if (uri.pathSegments.first == 'organization-register') {
      return MaterialPageRoute(
          settings: settings,
          builder: (context) => const Wrapper(
                OrganizationRegisterPage(),
                needsAuthentication: true,
              ));
    }

    if (uri.pathSegments.first == 'course') {
      String? courseIdStr = uri.queryParameters["id"];
      int courseId;

      bool isQueryProvided = courseIdStr != null;
      if (isQueryProvided) {
        courseId = int.parse(courseIdStr);
      } else {
        return MaterialPageRoute(
            settings: settings,
            builder: (context) => ErrorPage(
                error: networking_service.NetworkingException("invalid URL",
                    description: "a query was expected but not provided")));
      }

      return MaterialPageRoute(
          settings: settings,
          builder: (context) => Wrapper(CoursePage(courseId: courseId)));
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
    return MaterialPageRoute(builder: (context) => const Wrapper(AuthPage()));
  }
}

class ErrorPage extends StatelessWidget {
  // members of MyWidget
  final networking_service.NetworkingException error;

  // constructor
  const ErrorPage({Key? key, required this.error}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed("/login");
      error_service.reportError(error, context);
    });
    return Container();
  }
}

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
    course_service.sendToOrgPage(context);
    return Container();
  }
}
