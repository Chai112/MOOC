import 'package:flutter/material.dart';
import 'package:mooc/style/scholarly_appbar.dart';
import 'package:mooc/style/scholarly_colors.dart' as scholarly_color;
import 'package:mooc/style/widgets/scholarly_button.dart';
import 'package:mooc/style/widgets/scholarly_elements.dart';
import 'package:mooc/style/widgets/scholarly_text.dart';

import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:mooc/services/networking_service.dart' as networking_service;
import 'package:mooc/services/course_service.dart' as course_service;

// myPage class which creates a state on call
class OrganizationPage extends StatefulWidget {
  final int organizationId;
  const OrganizationPage({Key? key, required this.organizationId})
      : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<OrganizationPage> {
  String _orgName = "";
  final List<Map<String, dynamic>> _courses = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _loadName() async {
    String token = auth_service.globalUser.token!.token;

    Map<String, dynamic> response =
        await networking_service.getServer("getOrganization", {
      "token": token,
      "organizationId": widget.organizationId.toString(),
    });
    _orgName = Uri.decodeComponent(response["data"]["organizationName"]);
    return true;
  }

  Future<bool> _loadCourses() async {
    String token = auth_service.globalUser.token!.token;

    Map<String, dynamic> response2 =
        await networking_service.getServer("getCoursesFromOrganization", {
      "token": token,
      "organizationId": widget.organizationId.toString(),
    });
    for (int i = 0; i < response2["data"].length; i++) {
      _courses.add(response2["data"][i]);
    }
    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    print("loading");
    // ignore: unused_local_variable
    return ScholarlyScaffold(
      hasAppbar: true,
      body: [
        const SizedBox(height: 50),
        FutureBuilder(
            future: _loadName(),
            builder: (context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                return ScholarlyPadding(
                    verticalOnly: true, child: ScholarlyTextH2(_orgName));
              } else {
                return const ScholarlyLoading();
              }
            }),
        const SizedBox(height: 50),
      ],
      bottom: [
        const SizedBox(height: 50),
        ScholarlyButton("New", invertedColor: true, verticalOnlyPadding: true,
            onPressed: () {
          course_service.sendToCoursePage(context,
              organizationId: widget.organizationId);
        }),
        const SizedBox(height: 8),
        FutureBuilder(
            future: _loadCourses(),
            builder: (context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                return Column(
                    children: List.generate(_courses.length, (int i) {
                  return ScholarlyPadding(
                    verticalOnly: true,
                    child: ScholarlyTile(
                      child: InkWell(
                        onTap: () {
                          course_service.sendToCoursePage(context,
                              courseId: _courses[i]["courseId"]);
                        },
                        child: ScholarlyPadding(
                          child: SizedBox(
                              height: 70,
                              child: ScholarlyTextH3(Uri.decodeComponent(
                                  _courses[i]["courseName"]))),
                        ),
                      ),
                    ),
                  );
                }));
              } else {
                return const ScholarlyLoading();
              }
            }),
        Container(),
      ],
    );
  }
}
