import 'package:flutter/material.dart';
import 'package:mooc/pages/course/editor_page.dart';
import 'package:mooc/style/scholarly_appbar.dart';
import 'package:mooc/style/scholarly_colors.dart' as scholarly_color;
import 'package:mooc/style/widgets/scholarly_button.dart';
import 'package:mooc/style/widgets/scholarly_elements.dart';
import 'package:mooc/style/widgets/scholarly_text.dart';

import 'package:mooc/services/networking_service.dart' as networking_service;
import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:mooc/services/course_service.dart' as course_service;
import 'package:mooc/style/widgets/scholarly_text_field.dart';

// myPage class which creates a state on call
class CoursePage extends StatefulWidget {
  final int courseId;
  const CoursePage({Key? key, required this.courseId}) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<CoursePage> {
  String _courseName = "";
  final _courseNameController = ScholarlyTextFieldController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> loadData() async {
    String token = auth_service.globalUser.token!.token;

    Map<String, dynamic> response =
        await networking_service.getServer("getCourse", {
      "token": token,
      "courseId": widget.courseId.toString(),
    });
    _courseName = Uri.decodeComponent(response["data"]["courseName"]);
    _courseNameController.text = _courseName;
    return true;
  }

  void changeCourseName() async {
    String token = auth_service.globalUser.token!.token;
    await networking_service.getServer("changeCourseOptions", {
      "token": token,
      "courseId": widget.courseId.toString(),
      "courseName": _courseNameController.text,
      "courseDescription": "", // TODO: support course desc changing
    });

    setState(() {
      _courseName = _courseNameController.text;
    });
  }

  void removeCourse() async {
    String token = auth_service.globalUser.token!.token;
    await networking_service.getServer("removeCourse", {
      "token": token,
      "courseId": widget.courseId.toString(),
    });
    course_service.sendToOrgPage(context);
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return ScholarlyScaffold(
      numberOfTabs: 3,
      hasAppbar: true,
      sideBar: [
        ScholarlyButton("Delete Course", onPressed: removeCourse),
        ScholarlyTextH3("A")
      ],
      body: [
        const SizedBox(height: 20),
        FutureBuilder(
            future: loadData(),
            builder: (context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                return ScholarlyPadding(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwappableTextField(
                        textWidget: ScholarlyTextH2(_courseName),
                        textFieldWidget: ScholarlyTextField(
                            label: "course name",
                            controller: _courseNameController),
                        onSubmit: changeCourseName,
                      ),
                    ],
                  ),
                );
              } else {
                return const ScholarlyLoading();
              }
            }),
      ],
      tabNames: const [
        ScholarlyTabHeaders(
            tabName: "Editor", tabIcon: Icons.construction_rounded),
        ScholarlyTabHeaders(tabName: "Team", tabIcon: Icons.group_rounded),
        ScholarlyTabHeaders(
            tabName: "Insights", tabIcon: Icons.show_chart_rounded),
      ],
      tabs: [
        CourseEditorPage(),
        ScholarlyTabPage(body: [
          Text("B"),
        ]),
        ScholarlyTabPage(body: [
          Text("C"),
        ]),
      ],
    );
  }
}