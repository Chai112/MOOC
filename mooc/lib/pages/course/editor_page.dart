import 'package:flutter/material.dart';

import 'package:mooc/services/networking_service.dart' as networking_service;
import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:mooc/services/error_service.dart' as error_service;
import 'package:mooc/style/scholarly_colors.dart' as scholarly_color;
import 'package:mooc/style/widgets/scholarly_elements.dart';
import 'package:mooc/style/scholarly_appbar.dart';
import 'package:mooc/style/widgets/scholarly_text.dart';

import 'package:mooc/pages/course/editor/editor_sidebar_page.dart';

// myPage class which creates a state on call
class CourseEditorPage extends StatefulWidget {
  final int courseId;
  const CourseEditorPage({required this.courseId, Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<CourseEditorPage> {
  CourseHierarchyController _courseEditorController =
      CourseHierarchyController();
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
    return ScholarlyTabPage(sideBar: [
      SizedBox(height: 50),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CourseName(courseId: widget.courseId),
          const SizedBox(height: 30),
          CourseHierarchy(
              courseId: widget.courseId,
              controller: _courseEditorController,
              callback: (CourseHierarchyController newController) {
                setState(() {
                  _courseEditorController = newController;
                });
              }),
        ],
      ),
    ], body: [
      _CourseViewer(controller: _courseEditorController),
    ]);
  }
}

class CourseHierarchyController {
  String courseSectionName, courseElementName;
  int courseSectionId, courseElementId, courseElementType;
  bool isLoading;
  CourseHierarchyController({
    this.isLoading = true,
    this.courseSectionName = "",
    this.courseSectionId = 0,
    this.courseElementName = "",
    this.courseElementId = 0,
    this.courseElementType = 0,
  });
}

// myPage class which creates a state on call
class _CourseViewer extends StatefulWidget {
  final CourseHierarchyController controller;
  const _CourseViewer({Key? key, required this.controller}) : super(key: key);

  @override
  _CourseViewerState createState() => _CourseViewerState();
}

// myPage state
class _CourseViewerState extends State<_CourseViewer> {
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
    // ignore: unused_local_variable
    if (widget.controller.isLoading) return Container(child: Text("Loading "));

    return Container(
      child: Text(
          "${Uri.decodeComponent(widget.controller.courseSectionName)}/${Uri.decodeComponent(widget.controller.courseElementName)}"),
    );
  }
}
