import 'package:flutter/material.dart';
import 'package:mooc/pages/course/editor_page.dart';
import 'package:mooc/style/scholarly_appbar.dart';
import 'package:mooc/style/scholarly_colors.dart' as scholarly_color;
import 'package:mooc/style/widgets/scholarly_button.dart';
import 'package:mooc/style/widgets/scholarly_divider.dart';
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
      numberOfTabs: 4,
      hasAppbar: true,
      sideBar: [
        ScholarlyButton("Delete Course", onPressed: removeCourse),
        ScholarlyTextH3("A")
      ],
      body: [
        Align(alignment: Alignment(-1.1, 0), child: Text("Admin Controls:"))
      ],
      tabNames: const [
        ScholarlyTabHeaders(
            tabName: "Editor", tabIcon: Icons.construction_rounded),
        ScholarlyTabHeaders(
            tabName: "Insights", tabIcon: Icons.show_chart_rounded),
        ScholarlyTabHeaders(
            tabName: "Contributors", tabIcon: Icons.group_rounded),
        ScholarlyTabHeaders(tabName: "Students", tabIcon: Icons.person_rounded),
      ],
      tabs: [
        CourseEditorPage(courseId: widget.courseId),
        ScholarlyTabPage(body: [
          Center(child: Text("Work in Progress")),
        ]),
        ScholarlyTabPage(body: [
          Center(child: Text("Work in Progress")),
        ]),
        ScholarlyTabPage(body: [
          Center(child: Text("Work in Progress")),
        ]),
      ],
    );
  }
}
