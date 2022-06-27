import 'package:flutter/material.dart';
import 'package:mooc/style/scholarly_appbar.dart';
import 'package:mooc/style/scholarly_colors.dart' as scholarly_color;

import 'package:mooc/services/networking_service.dart' as networking_service;
import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:mooc/style/widgets/scholarly_elements.dart';
import 'package:mooc/style/widgets/scholarly_text.dart';
import 'package:mooc/style/widgets/scholarly_text_field.dart';

// This is the type used by the popup menu below.
enum CourseElementTypes { video, literature, form }

// myPage class which creates a state on call
class CourseEditorPage extends StatefulWidget {
  final int courseId;
  const CourseEditorPage({required this.courseId, Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _CourseSection {
  String courseSectionName = "";
  int courseSectionId = 0;
  List<_CourseElement> courseElements = [];
}

class _CourseElement {
  String courseElementName = "";
  int courseElementId = 0;
  int courseElementType = 0;
}

// myPage state
class _State extends State<CourseEditorPage> {
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
          _CourseName(courseId: widget.courseId),
          const SizedBox(height: 30),
          _CourseHierarchy(courseId: widget.courseId),
        ],
      ),
    ], body: [
      Text("A"),
    ]);
  }
}

class _CourseName extends StatefulWidget {
  final int courseId;
  const _CourseName({Key? key, required this.courseId}) : super(key: key);

  @override
  _CourseNameState createState() => _CourseNameState();
}

class _CourseNameState extends State<_CourseName> {
  String _courseName = "";
  final _courseNameController = ScholarlyTextFieldController();

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

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return FutureBuilder(
        future: loadCourseName(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return ScholarlyPadding(
              child: SwappableTextField(
                textWidget: ScholarlyTextH2(_courseName),
                textFieldWidget: ScholarlyTextField(
                    label: "course name", controller: _courseNameController),
                onSubmit: changeCourseName,
              ),
            );
          } else {
            return const ScholarlyLoading();
          }
        });
  }
}

class _CourseHierarchy extends StatefulWidget {
  final int courseId;
  const _CourseHierarchy({Key? key, required this.courseId}) : super(key: key);

  @override
  _CourseHierarchyState createState() => _CourseHierarchyState();
}

class _CourseHierarchyState extends State<_CourseHierarchy> {
  int _selectedCourseSection = 0;
  int _selectedCourseElement = 0;
  List<_CourseSection> _courseHierarchy = [];

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
      var courseSectionJson = response["data"][i];
      courseSection.courseSectionName = courseSectionJson["courseSectionName"];
      courseSection.courseSectionId = courseSectionJson["courseSectionId"];

      for (int j = 0; j < response["data"][i]["children"].length; j++) {
        _CourseElement courseElement = _CourseElement();
        var courseElementJson = response["data"][i]["children"][j];
        courseElement.courseElementId = courseElementJson["courseElementId"];
        courseElement.courseElementName =
            courseElementJson["courseElementName"];
        courseElement.courseElementType =
            courseElementJson["courseElementType"];

        courseSection.courseElements.add(courseElement);
      }
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

  Future<bool> addCourseElementVideo(int courseSectionId) async {
    String token = auth_service.globalUser.token!.token;

    Map<String, dynamic> response =
        await networking_service.getServer("createVideo", {
      "token": token,
      "courseSectionId": courseSectionId.toString(),
      "courseElementName": "New Video",
    });

    int courseElementId = response["courseElementId"];
    return true;
  }

  Future<bool> addCourseElementLiterature(int courseSectionId) async {
    String token = auth_service.globalUser.token!.token;

    Map<String, dynamic> response =
        await networking_service.getServer("createLiterature", {
      "token": token,
      "courseSectionId": courseSectionId.toString(),
      "courseElementName": "New Literature",
      "literatureData": "",
    });

    int courseElementId = response["courseElementId"];
    return true;
  }

  Future<bool> addCourseElementForm(int courseSectionId) async {
    String token = auth_service.globalUser.token!.token;

    Map<String, dynamic> response =
        await networking_service.getServer("createForm", {
      "token": token,
      "courseSectionId": courseSectionId.toString(),
      "courseElementName": "New Test",
      "formData": "",
    });

    int courseElementId = response["courseElementId"];
    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return FutureBuilder(
        future: loadCourseHierarchy(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          //if (snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
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
                              children: List.generate(
                                  _courseHierarchy[i].courseElements.length,
                                  (int j) {
                                _CourseElement courseElement =
                                    _courseHierarchy[i].courseElements[j];
                                String courseElementName =
                                    courseElement.courseElementName;
                                IconData courseElementIcon = Icons.help;
                                switch (courseElement.courseElementType) {
                                  case 0:
                                    courseElementIcon = Icons.videocam_rounded;
                                    break;
                                  case 1:
                                    courseElementIcon = Icons.article_rounded;
                                    break;
                                  case 2:
                                    courseElementIcon = Icons.school_rounded;
                                    break;
                                }

                                return ScholarlyHoverButton(
                                  child: ScholarlySideBarButton(
                                      icon: courseElementIcon,
                                      label: Uri.decodeComponent(
                                          courseElementName),
                                      selected: i == _selectedCourseSection &&
                                          j == _selectedCourseElement,
                                      onPressed: () {
                                        setState(() {
                                          _selectedCourseSection = i;
                                          _selectedCourseElement = j;
                                        });
                                      }),
                                );
                              }),
                            ),
                            _PopupAddElement(
                                onPressed: (CourseElementTypes item) async {
                              switch (item) {
                                case CourseElementTypes.video:
                                  setState(() {
                                    addCourseElementVideo(
                                        _courseHierarchy[i].courseSectionId);
                                  });
                                  break;
                                case CourseElementTypes.literature:
                                  setState(() {
                                    addCourseElementLiterature(
                                        _courseHierarchy[i].courseSectionId);
                                  });
                                  break;
                                case CourseElementTypes.form:
                                  setState(() {
                                    addCourseElementForm(
                                        _courseHierarchy[i].courseSectionId);
                                  });
                                  break;
                              }
                            }),
                            Container(),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
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
          );
          //} else {
          //return const ScholarlyLoading();
          //}
        });
  }
}

class _PopupAddElement extends StatelessWidget {
  // members of MyWidget
  final Function(CourseElementTypes) onPressed;

  // constructor
  const _PopupAddElement({Key? key, required this.onPressed}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<CourseElementTypes>(
        icon: const Icon(Icons.add_rounded, color: scholarly_color.greyLight),
        tooltip: "Add element",
        // Callback that sets the selected popup menu item.
        onSelected: onPressed,
        itemBuilder: (BuildContext context) =>
            <PopupMenuEntry<CourseElementTypes>>[
              PopupMenuItem<CourseElementTypes>(
                value: CourseElementTypes.video,
                child: Row(
                  children: const [
                    Icon(Icons.videocam_rounded),
                    SizedBox(width: 10),
                    Text('Add Video'),
                  ],
                ),
              ),
              PopupMenuItem<CourseElementTypes>(
                value: CourseElementTypes.literature,
                child: Row(
                  children: const [
                    Icon(Icons.article_rounded),
                    SizedBox(width: 10),
                    Text('Add Literature'),
                  ],
                ),
              ),
              PopupMenuItem<CourseElementTypes>(
                value: CourseElementTypes.form,
                child: Row(children: const [
                  Icon(Icons.school_rounded),
                  SizedBox(width: 10),
                  Text('Add Test'),
                ]),
              ),
            ]);
  }
}
