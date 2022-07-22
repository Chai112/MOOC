import 'package:flutter/material.dart';
import 'package:mooc/services/networking_service.dart' as networking_service;
import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:mooc/services/error_service.dart' as error_service;

import 'package:mooc/style/scholarly_colors.dart' as scholarly_color;
import 'package:mooc/style/widgets/scholarly_button.dart';
import 'package:mooc/style/widgets/scholarly_elements.dart';
import 'package:mooc/style/scholarly_appbar.dart';
import 'package:mooc/style/widgets/scholarly_text.dart';
import 'package:mooc/style/widgets/scholarly_text_field.dart';

import 'package:mooc/pages/course/editor_page.dart';

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

class CourseName extends StatefulWidget {
  final int courseId;
  const CourseName({Key? key, required this.courseId}) : super(key: key);

  @override
  _CourseNameState createState() => _CourseNameState();
}

class _CourseNameState extends State<CourseName> {
  String _courseName = "";
  final _courseNameController = ScholarlyTextFieldController();

  Future<bool> loadCourseName() async {
    String token = auth_service.globalUser.token!.token;

    Map<String, dynamic> response =
        await networking_service.serverGet("getCourse", {
      "token": token,
      "courseId": widget.courseId.toString(),
    });
    _courseName = Uri.decodeComponent(response["data"]["courseName"]);
    _courseNameController.text = _courseName;
    return true;
  }

  void changeCourseName() async {
    String token = auth_service.globalUser.token!.token;
    await networking_service.serverGet("changeCourseOptions", {
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
            return SizedBox(
              width: 300,
              child: SwappableTextField(
                textWidget: ScholarlyTextH2B(_courseName),
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

class CourseHierarchy extends StatefulWidget {
  final int courseId;
  final CourseHierarchyController controller;
  final Function(CourseHierarchyController) callback;
  const CourseHierarchy(
      {Key? key,
      required this.courseId,
      required this.controller,
      required this.callback})
      : super(key: key);

  @override
  _CourseHierarchyState createState() => _CourseHierarchyState();
}

class _CourseHierarchyState extends State<CourseHierarchy> {
  int _selectedCourseSection = 0;
  int _selectedCourseElement = 0;
  List<_CourseSection> _courseHierarchy = [];

  Future<bool> loadCourseHierarchy() async {
    String token = auth_service.globalUser.token!.token;

    Map<String, dynamic> response =
        await networking_service.serverGet("getCourseHierarchy", {
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
    _updateController();
    return true;
  }

  void _updateController() {
    if (widget.controller.courseElementId !=
        _courseHierarchy[_selectedCourseSection]
            .courseElements[_selectedCourseElement]
            .courseElementId) {
      widget.callback(CourseHierarchyController(
        courseSectionId:
            _courseHierarchy[_selectedCourseSection].courseSectionId,
        courseSectionName:
            _courseHierarchy[_selectedCourseSection].courseSectionName,
        courseElementId: _courseHierarchy[_selectedCourseSection]
            .courseElements[_selectedCourseElement]
            .courseElementId,
        courseElementName: _courseHierarchy[_selectedCourseSection]
            .courseElements[_selectedCourseElement]
            .courseElementName,
        courseElementType: _courseHierarchy[_selectedCourseSection]
            .courseElements[_selectedCourseElement]
            .courseElementType,
        isLoading: false,
      ));
    }
  }

  Future<bool> addCourseSection() async {
    String token = auth_service.globalUser.token!.token;

    Map<String, dynamic> response =
        await networking_service.serverGet("createCourseSection", {
      "token": token,
      "courseId": widget.courseId.toString(),
      "courseSectionName": "New Course Section",
    });

    int courseSectionId = response["courseSectionId"];
    return true;
  }

  void _addElementButton(_AddElementTypes item, int courseSectionId) async {
    switch (item) {
      case _AddElementTypes.video:
        String token = auth_service.globalUser.token!.token;

        await networking_service.serverGet("createVideo", {
          "token": token,
          "courseSectionId": courseSectionId.toString(),
          "courseElementName": "Untitled Video",
        });

        setState(() {});
        break;
      case _AddElementTypes.literature:
        String token = auth_service.globalUser.token!.token;

        await networking_service.serverGet("createLiterature", {
          "token": token,
          "courseSectionId": courseSectionId.toString(),
          "courseElementName": "Untitled Literature",
          "literatureData": "",
        });
        setState(() {});

        break;
      case _AddElementTypes.form:
        String token = auth_service.globalUser.token!.token;

        await networking_service.serverGet("createForm", {
          "token": token,
          "courseSectionId": courseSectionId.toString(),
          "courseElementName": "Untitled Test",
          "formData": "",
        });

        setState(() {});
        break;
    }
  }

  void _editElementButton(
      _EditElementTypes item, int courseSectionId, int courseElementId) {
    String token = auth_service.globalUser.token!.token;
    switch (item) {
      case _EditElementTypes.rename:
        setState(() {
          int i = 0, j = 0;
          while (_courseHierarchy[i].courseSectionId != courseSectionId) {
            i++;
          }
          while (_courseHierarchy[i].courseElements[j].courseElementId !=
              courseElementId) {
            j++;
          }
          String courseElementName = Uri.decodeComponent(
              _courseHierarchy[i].courseElements[j].courseElementName);

          error_service.alert(error_service.Alert(
              title: "Rename $courseElementName",
              description: "Please enter a new name",
              buttonName: "RENAME",
              prefillInputText: courseElementName,
              acceptInput: true,
              callback: (String input) async {
                await networking_service.serverGet("changeCourseElement", {
                  "token": token,
                  "courseElementId": courseElementId.toString(),
                  "courseElementName": input,
                  "courseElementDescription": "",
                });
                setState(() {});
              }));
        });
        break;
      case _EditElementTypes.move:
        setState(() {});
        break;
      case _EditElementTypes.delete:
        setState(() {
          int i = 0, j = 0;
          while (_courseHierarchy[i].courseSectionId != courseSectionId) {
            i++;
          }
          while (_courseHierarchy[i].courseElements[j].courseElementId !=
              courseElementId) {
            j++;
          }
          String courseElementName = Uri.decodeComponent(
              _courseHierarchy[i].courseElements[j].courseElementName);

          error_service.alert(error_service.Alert(
              title: "Delete $courseElementName",
              description:
                  "Are you sure you wish to permanently delete $courseElementName?\nAll data will be lost forever.",
              buttonName: "DELETE",
              acceptInput: false,
              callback: (String input) async {
                await networking_service.serverGet("removeCourseElement", {
                  "token": token,
                  "courseElementId": courseElementId.toString(),
                });
                setState(() {});
              }));
        });
        break;
    }
  }

  void _editSectionButton(_EditSectionTypes item, int courseSectionId) {
    String token = auth_service.globalUser.token!.token;
    switch (item) {
      case _EditSectionTypes.rename:
        setState(() {
          int i = 0;
          while (_courseHierarchy[i].courseSectionId != courseSectionId) {
            i++;
          }
          String courseSectionName =
              Uri.decodeComponent(_courseHierarchy[i].courseSectionName);

          error_service.alert(error_service.Alert(
              title: "Rename $courseSectionName",
              description: "Please enter a new name",
              buttonName: "RENAME",
              prefillInputText: courseSectionName,
              acceptInput: true,
              callback: (String input) async {
                await networking_service.serverGet("changeCourseSection", {
                  "token": token,
                  "courseSectionId": courseSectionId.toString(),
                  "courseSectionName": input,
                });
                setState(() {});
              }));
        });
        break;
      case _EditSectionTypes.move:
        setState(() {});
        break;
      case _EditSectionTypes.delete:
        setState(() {
          int i = 0;
          while (_courseHierarchy[i].courseSectionId != courseSectionId) {
            i++;
          }
          String courseSectionName =
              Uri.decodeComponent(_courseHierarchy[i].courseSectionName);

          error_service.alert(error_service.Alert(
              title: "Delete $courseSectionName",
              description:
                  "Are you sure you wish to permanently delete $courseSectionName?\nAll data will be lost forever.",
              buttonName: "DELETE",
              acceptInput: false,
              callback: (String input) async {
                await networking_service.serverGet("removeCourseSection", {
                  "token": token,
                  "courseSectionId": courseSectionId.toString(),
                });
                setState(() {});
              }));
        });
        break;
    }
  }

  int a = 0;
  // main build function
  @override
  Widget build(BuildContext context) {
    error_service.checkAlerts(context);
    // ignore: unused_local_variable
    return FutureBuilder(
        future: loadCourseHierarchy(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: List.generate(_courseHierarchy.length, (int i) {
                  _CourseSection courseSection = _courseHierarchy[i];
                  return ScholarlyHoverButton(
                    button: _PopupEditSectionButton(
                      onPressed: (_EditSectionTypes item) {
                        _editSectionButton(item, courseSection.courseSectionId);
                      },
                    ),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.only(left: 10),
                      iconColor: scholarly_color.grey,
                      initiallyExpanded: i == _selectedCourseSection,
                      title: Align(
                        alignment: Alignment(-1.65, 0),
                        child: SizedBox(
                          width: 200,
                          child: ScholarlyTextH5(
                              Uri.decodeComponent(
                                  courseSection.courseSectionName),
                              red: false),
                        ),
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
                                    courseSection.courseElements.length,
                                    (int j) {
                                  _CourseElement courseElement =
                                      courseSection.courseElements[j];
                                  String courseElementName =
                                      courseElement.courseElementName;
                                  IconData courseElementIcon = Icons.help;
                                  switch (courseElement.courseElementType) {
                                    case 0:
                                      courseElementIcon =
                                          Icons.videocam_rounded;
                                      break;
                                    case 1:
                                      courseElementIcon = Icons.article_rounded;
                                      break;
                                    case 2:
                                      courseElementIcon = Icons.school_rounded;
                                      break;
                                  }

                                  return ScholarlyHoverButton(
                                    button: _PopupEditElementButton(
                                      onPressed: (_EditElementTypes item) {
                                        _editElementButton(
                                            item,
                                            courseSection.courseSectionId,
                                            courseElement.courseElementId);
                                      },
                                    ),
                                    child: ScholarlySideBarButton(
                                        icon: courseElementIcon,
                                        label: Uri.decodeComponent(
                                            courseElementName),
                                        selected: i == _selectedCourseSection &&
                                            j == _selectedCourseElement,
                                        onPressed: () {
                                          _selectedCourseSection = i;
                                          _selectedCourseElement = j;
                                          _updateController();
                                          setState(() {});
                                        }),
                                  );
                                }),
                              ),
                              _PopupAddElementButton(
                                  onPressed: (_AddElementTypes item) {
                                _addElementButton(
                                    item, courseSection.courseSectionId);
                              }),
                              Container(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              ScholarlyButton(
                "Add Section",
                lightenBackground: true,
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

// This is the type used by the popup menu below.
enum _AddElementTypes { video, literature, form }

class _PopupAddElementButton extends StatelessWidget {
  // members of MyWidget
  final Function(_AddElementTypes) onPressed;

  // constructor
  const _PopupAddElementButton({Key? key, required this.onPressed})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_AddElementTypes>(
        icon: const Icon(Icons.add_rounded, color: scholarly_color.borderColor),
        tooltip: "Add element",
        // Callback that sets the selected popup menu item.
        onSelected: onPressed,
        itemBuilder: (BuildContext context) =>
            <PopupMenuEntry<_AddElementTypes>>[
              PopupMenuItem<_AddElementTypes>(
                value: _AddElementTypes.video,
                child: Row(
                  children: const [
                    Icon(Icons.videocam_rounded),
                    SizedBox(width: 10),
                    Text('Add Video'),
                  ],
                ),
              ),
              PopupMenuItem<_AddElementTypes>(
                value: _AddElementTypes.literature,
                child: Row(
                  children: const [
                    Icon(Icons.article_rounded),
                    SizedBox(width: 10),
                    Text('Add Literature'),
                  ],
                ),
              ),
              PopupMenuItem<_AddElementTypes>(
                value: _AddElementTypes.form,
                child: Row(children: const [
                  Icon(Icons.school_rounded),
                  SizedBox(width: 10),
                  Text('Add Test'),
                ]),
              ),
            ]);
  }
}

// This is the type used by the popup menu below.
enum _EditElementTypes { rename, move, delete }

class _PopupEditElementButton extends StatelessWidget {
  // members of MyWidget
  final Function(_EditElementTypes) onPressed;

  // constructor
  const _PopupEditElementButton({Key? key, required this.onPressed})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_EditElementTypes>(
        icon: const Icon(Icons.more_vert_rounded, color: Colors.black26),
        tooltip: "Edit",
        // Callback that sets the selected popup menu item.
        onSelected: onPressed,
        itemBuilder: (BuildContext context) =>
            <PopupMenuEntry<_EditElementTypes>>[
              PopupMenuItem<_EditElementTypes>(
                onTap: () {
                  onPressed(_EditElementTypes.rename);
                },
                child: const Text('Rename'),
              ),
              /*
              const PopupMenuItem<_EditElementTypes>(
                value: _EditElementTypes.move,
                child: Text('Move'),
              ),
              */
              PopupMenuItem<_EditElementTypes>(
                value: _EditElementTypes.delete,
                onTap: () {
                  onPressed(_EditElementTypes.delete);
                },
                child: const Text('Delete'),
              ),
            ]);
  }
}

// This is the type used by the popup menu below.
enum _EditSectionTypes { rename, move, delete }

class _PopupEditSectionButton extends StatelessWidget {
  // members of MyWidget
  final Function(_EditSectionTypes) onPressed;

  // constructor
  const _PopupEditSectionButton({Key? key, required this.onPressed})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_EditSectionTypes>(
        icon: const Icon(Icons.more_vert_rounded, color: Colors.black26),
        tooltip: "Edit",
        // Callback that sets the selected popup menu item.
        itemBuilder: (BuildContext context) =>
            <PopupMenuEntry<_EditSectionTypes>>[
              PopupMenuItem<_EditSectionTypes>(
                onTap: () {
                  onPressed(_EditSectionTypes.rename);
                },
                child: const Text('Rename'),
              ),
              /*
              const PopupMenuItem<_EditSectionTypes>(
                value: _EditSectionTypes.move,
                child: Text('Move'),
              ),
              */
              PopupMenuItem<_EditSectionTypes>(
                onTap: () {
                  onPressed(_EditSectionTypes.delete);
                },
                child: const Text('Delete'),
              ),
            ]);
  }
}
