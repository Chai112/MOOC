import 'package:flutter/material.dart';
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

  Future<bool> loadCourses() async {
    String token = auth_service.globalUser.token!.token;

    Map<String, dynamic> response =
        await networking_service.getServer("getOrganization", {
      "token": token,
      "organizationId": widget.organizationId.toString(),
    });
    _orgName = Uri.decodeComponent(response["data"]["organizationName"]);

    Map<String, dynamic> response2 =
        await networking_service.getServer("getCoursesFromOrganization", {
      "token": token,
      "organizationId": widget.organizationId.toString(),
    });
    for (int i = 0; i < response2["data"].length; i++) {
      _courses.add(response2["data"][i]);
    }
    print(_courses);
    return false;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return Scaffold(
      /*
      appBar: AppBar(
        title: Container(
            height: 20,
          child:
                Image(fit: BoxFit.fill, image: AssetImage('assets/logo.png'))),
      ),
      */
      body: Stack(
        children: [
          SizedBox(
            width: 350,
            child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [scholarly_color.shadow],
                ),
                child: FutureBuilder(
                    future: loadCourses(),
                    builder: (context, AsyncSnapshot<bool> snapshot) {
                      if (snapshot.hasData) {
                        return ScholarlyPadding(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ScholarlyPadding(
                                  verticalOnly: true,
                                  child: ScholarlyTextH2(_orgName)),
                              const ScholarlyPadding(
                                  verticalOnly: true,
                                  child: ScholarlyTextH3("Select a course:")),
                              Expanded(
                                child: ListView.builder(
                                    itemCount: _courses.length,
                                    itemBuilder: (BuildContext context, int i) {
                                      return InkWell(
                                          onTap: () {},
                                          highlightColor: Colors.black,
                                          child: ScholarlyPadding(
                                            verticalOnly: true,
                                            child: ScholarlyTile(
                                                hasShadows: false,
                                                child: ScholarlyPadding(
                                                  child: SizedBox(
                                                      height: 100,
                                                      child: ScholarlyTextH3(
                                                          _courses[i]
                                                              ["courseName"])),
                                                )),
                                          ));
                                    }),
                              ),
                              ScholarlyButton("Create Course",
                                  invertedColor: true, onPressed: () {
                                course_service.sendToCoursePage(context,
                                    organizationId: widget.organizationId);
                              }),
                            ],
                          ),
                        );
                      } else {
                        return const LinearProgressIndicator();
                      }
                    })),
          ),
          Row(
            children: [
              const SizedBox(width: 350),
              ScholarlyHolder(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 200),
                    ScholarlyTextH2(
                        "Welcome back, ${auth_service.globalUser.username}"),
                    Container(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
