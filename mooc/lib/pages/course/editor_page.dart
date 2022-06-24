import 'package:flutter/material.dart';
import 'package:mooc/style/scholarly_appbar.dart';

// myPage class which creates a state on call
class CourseEditorPage extends StatefulWidget {
  const CourseEditorPage({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
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
      const SizedBox(height: 70),
      Column(
        children: List.generate(_courseModules.length, (int i) {
          return ScholarlySideBarButton(
              label: _courseModules[i],
              icon: Icons.bookmark,
              selected: i == _selectedCourseModule,
              onPressed: () {
                setState(() {
                  _selectedCourseModule = i;
                });
              });
        }),
      ),
    ], body: [
      Text("A"),
    ]);
  }
}
