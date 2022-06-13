import 'package:flutter/material.dart';
import 'package:mooc/style/scholarly_colors.dart' as scholarly_color;
import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:mooc/style/widgets/scholarly_elements.dart';
import 'package:mooc/style/widgets/scholarly_text.dart';

// myPage class which creates a state on call
class OrganizationPage extends StatefulWidget {
  const OrganizationPage({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<OrganizationPage> {
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
                      const ScholarlyPadding(
                          verticalOnly: true,
                          child: ScholarlyTextH3("Select a course:")),
                      Expanded(
                        child: ListView.builder(
                            itemCount: 5,
                            itemBuilder: (BuildContext context, int index) {
                              return const ScholarlyPadding(
                                verticalOnly: true,
                                child: ScholarlyTile(
                                    hasShadows: false,
                                    child: ScholarlyPadding(
                                      child: SizedBox(
                                          height: 100,
                                          child: ScholarlyTextH3("Course A")),
                                    )),
                              );
                            }),
                      )
                    ],
                  ),
                )),
          ),
          Row(
            children: [
              const SizedBox(width: 350),
              ScholarlyHolder(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 200),
                    ScholarlyTextH2(
                        "Welcome back, ${auth_service.globalUser.username}"),
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
