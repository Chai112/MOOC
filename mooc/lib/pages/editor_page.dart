import 'package:flutter/material.dart';
import 'package:mooc/style/scholarly_colors.dart' as scholarly_color;
import 'package:mooc/style/widgets/scholarly_button.dart';
import 'package:mooc/style/widgets/scholarly_elements.dart';
import 'package:mooc/style/widgets/scholarly_text.dart';

import 'package:mooc/services/networking_service.dart' as networking_service;
import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:mooc/services/course_service.dart' as course_service;
import 'package:mooc/style/widgets/scholarly_text_field.dart';

// myPage class which creates a state on call
class EditorPage extends StatefulWidget {
  final int courseId;
  const EditorPage({Key? key, required this.courseId}) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<EditorPage> {
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
                bottom:
                    BorderSide(color: scholarly_color.highlightGrey, width: 1)),
            //boxShadow: [scholarly_color.shadow],
          ),
        ),
        title: Container(
            height: 20,
            child:
                Image(fit: BoxFit.fill, image: AssetImage('assets/logo.png'))),
      ),
      body: Stack(
        children: [
          SizedBox(
            width: 350,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                    right: BorderSide(
                        color: scholarly_color.highlightGrey, width: 1)),
                //boxShadow: [scholarly_color.shadow],
              ),
              child: FutureBuilder(
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
                            ScholarlyButton("Delete Course",
                                onPressed: removeCourse)
                          ],
                        ),
                      );
                    } else {
                      return const LinearProgressIndicator();
                    }
                  }),
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 350),
              ScholarlyHolder(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 200),
                    ScholarlyTextH2("Course Editor"),
                    Text(widget.courseId.toString()),
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
