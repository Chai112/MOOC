import 'package:flutter/material.dart';
import 'package:mooc/style/scholarly_appbar.dart';
import 'package:mooc/style/scholarly_colors.dart' as scholarly_color;

import 'package:mooc/services/networking_service.dart' as networking_service;
import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:mooc/style/widgets/scholarly_elements.dart';
import 'package:mooc/style/widgets/scholarly_text.dart';
import 'package:mooc/style/widgets/scholarly_text_field.dart';

// This is the type used by the popup menu below.
enum Menu { video, reading, test }

// myPage class which creates a state on call
class CourseEditorPage extends StatefulWidget {
  final int courseId;
  const CourseEditorPage({required this.courseId, Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _CourseSection {
  String courseSectionName = "";
  List<String> courseElementNames = [];
}

// myPage state
class _State extends State<CourseEditorPage> {
  List<String> _courseModules = [
    "Course Module 1",
    "Course Module 2",
    "Course Module 3",
    "Course Module 4"
  ];
  int _selectedCourseModule = 0;
  String _courseName = "";
  List<_CourseSection> _courseHierarchy = [];
  final _courseNameController = ScholarlyTextFieldController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> loadCourseName() async {
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

  Future<bool> loadCourseHierarchy() async {
    String token = auth_service.globalUser.token!.token;

    Map<String, dynamic> response =
        await networking_service.getServer("getCourseHierarchy", {
      "token": token,
      "courseId": widget.courseId.toString(),
    });

    _courseHierarchy = []; // reset
    for (int i = 0; i < response["data"].length; i++) {
      _CourseSection courseSection = _CourseSection();
      courseSection.courseSectionName =
          response["data"][i]["courseSectionName"];
      _courseHierarchy.add(courseSection);
    }
    return true;
  }

  Future<bool> addCourseSection() async {
    String token = auth_service.globalUser.token!.token;

    Map<String, dynamic> response =
        await networking_service.getServer("createCourseSection", {
      "token": token,
      "courseId": widget.courseId.toString(),
      "courseSectionName": "New Course Section",
    });

    int courseSectionId = response["courseSectionId"];
    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarlyTabPage(sideBar: [
      Flexible(flex: 1, child: Container()),
      Flexible(
        flex: 9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
                future: loadCourseName(),
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.hasData) {
                    return ScholarlyPadding(
                      child: SwappableTextField(
                        textWidget: ScholarlyTextH2(_courseName),
                        textFieldWidget: ScholarlyTextField(
                            label: "course name",
                            controller: _courseNameController),
                        onSubmit: changeCourseName,
                      ),
                    );
                  } else {
                    return const ScholarlyLoading();
                  }
                }),
            const SizedBox(height: 30),
            FutureBuilder(
                future: loadCourseHierarchy(),
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  //if (snapshot.hasData) {
                  return Column(
                    children: List.generate(_courseHierarchy.length, (int i) {
                      return ExpansionTile(
                        tilePadding: EdgeInsets.only(left: 10),
                        iconColor: scholarly_color.grey,
                        title: Align(
                          alignment: Alignment(-1.45, 0),
                          child: ScholarlyTextH5(
                              Uri.decodeComponent(
                                  _courseHierarchy[i].courseSectionName),
                              red: false),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ScholarlySideBarButton(
                                        icon: Icons.article_rounded,
                                        label: "Introduction",
                                        selected: i == _selectedCourseModule,
                                        onPressed: () {
                                          setState(() {
                                            _selectedCourseModule = i;
                                          });
                                        }),
                                  ],
                                ),
                                _PopupAddElement(onPressed: (Menu item) {
                                  switch (item) {
                                    case Menu.video:
                                      break;
                                    case Menu.reading:
                                      break;
                                    case Menu.test:
                                      break;
                                  }
                                  print(item);
                                }),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  );
                  //} else {
                  //return const ScholarlyLoading();
                  //}
                }),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: scholarly_color.greyLight),
              tooltip: "Add section",
              onPressed: () async {
                await addCourseSection();
                setState(() {});
              },
            )
          ],
        ),
      ),
    ], body: [
      Text("A"),
    ]);
  }
}

class _PopupAddElement extends StatelessWidget {
  // members of MyWidget
  final Function(Menu) onPressed;

  // constructor
  const _PopupAddElement({Key? key, required this.onPressed}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Menu>(
        icon: const Icon(Icons.add_rounded, color: scholarly_color.greyLight),
        tooltip: "Add element",
        // Callback that sets the selected popup menu item.
        onSelected: onPressed,
        itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
              PopupMenuItem<Menu>(
                value: Menu.video,
                child: Row(
                  children: const [
                    Icon(Icons.videocam_rounded),
                    SizedBox(width: 10),
                    Text('Add Video'),
                  ],
                ),
              ),
              PopupMenuItem<Menu>(
                value: Menu.reading,
                child: Row(
                  children: const [
                    Icon(Icons.article_rounded),
                    SizedBox(width: 10),
                    Text('Add Reading'),
                  ],
                ),
              ),
              PopupMenuItem<Menu>(
                value: Menu.test,
                child: Row(children: const [
                  Icon(Icons.quiz_rounded),
                  SizedBox(width: 10),
                  Text('Add Test'),
                ]),
              ),
            ]);
  }
}
