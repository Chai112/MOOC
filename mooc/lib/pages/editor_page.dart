import 'package:flutter/material.dart';
import 'package:mooc/style/scholarly_colors.dart' as scholarly_color;
import 'package:mooc/style/widgets/scholarly_button.dart';
import 'package:mooc/style/widgets/scholarly_elements.dart';
import 'package:mooc/style/widgets/scholarly_text.dart';

// myPage class which creates a state on call
class EditorPage extends StatefulWidget {
  final int courseId;
  const EditorPage({Key? key, required this.courseId}) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<EditorPage> {
  String _orgName = "";
  List<Map<String, dynamic>> _courses = [];

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
              child: ScholarlyPadding(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScholarlyButton("Create Course",
                        invertedColor: true, onPressed: () {}),
                  ],
                ),
              ),
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
