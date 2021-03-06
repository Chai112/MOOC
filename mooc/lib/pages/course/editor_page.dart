import 'package:flutter/material.dart';

import 'package:mooc/services/networking_service.dart' as networking_service;
import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:mooc/services/error_service.dart' as error_service;
import 'package:mooc/style/scholarly_colors.dart' as scholarly_color;
import 'package:mooc/style/widgets/scholarly_elements.dart';
import 'package:mooc/style/scholarly_appbar.dart';
import 'package:flutter/scheduler.dart';
import 'package:mooc/style/widgets/scholarly_text.dart';

import 'package:mooc/pages/course/editor/editor_sidebar_page.dart';
import 'package:mooc/pages/course/editor/editor_video_page.dart';

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
      _CourseViewer(
          controller: _courseEditorController,
          callback: () {
            setState(() {});
          }),
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
  final Function() callback;
  const _CourseViewer(
      {Key? key, required this.controller, required this.callback})
      : super(key: key);

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

  // this is dirty code, but the code needs to reset a widget before returning it.
  // To do this, we must first load a Container() in between widget loadings.
  // Otherwise, if the loading returns the same widget, it will not init state again.
  Future<void> _load() async {
    await Future.delayed(const Duration(microseconds: 1), () {});
    setState(() {});
  }

  bool _isLoaded = false;
  // main build function
  @override
  Widget build(BuildContext context) {
    _isLoaded = !_isLoaded;
    if (_isLoaded) {
      // ignore: unused_local_variable
      if (widget.controller.isLoading)
        return Container(child: Text("Loading "));
      switch (widget.controller.courseElementType) {
        case 0:
          return CourseEditorVideoPage(
              controller: widget.controller,
              callback: () {
                widget.callback();
              });
        case 1:
        case 2:
      }

      return Container(
        child: Text(
            "${Uri.decodeComponent(widget.controller.courseSectionName)}/${Uri.decodeComponent(widget.controller.courseElementName)}"),
      );
    } else {
      _load();
      return Container();
    }
  }
}
