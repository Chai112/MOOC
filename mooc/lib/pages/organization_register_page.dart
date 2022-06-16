import 'package:flutter/material.dart';
import 'package:mooc/style/widgets/scholarly_button.dart';
import 'package:mooc/style/widgets/scholarly_elements.dart';
import 'package:mooc/style/widgets/scholarly_text.dart';

import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:mooc/services/networking_service.dart' as networking_service;
import 'package:mooc/services/course_service.dart' as course_service;

// myPage class which creates a state on call
class OrganizationRegisterPage extends StatefulWidget {
  const OrganizationRegisterPage({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<OrganizationRegisterPage> {
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
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScholarlyTile(
            hasShadows: true,
            width: 470,
            child: ScholarlyPadding(
              thick: true,
              child: Column(
                children: [
                  const ScholarlyTextH3("Organizations"),
                  const ScholarlyTextP(
                      "Organizations are a collection of courses and teachers who can edit those courses.",
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ScholarlyButton("Create your own organization",
                      invertedColor: true, onPressed: () async {
                    String token = auth_service.globalUser.token!.token;
                    Map<String, dynamic> response2 = await networking_service
                        .getServer("createOrganization", {
                      "token": token,
                      "organizationName": "s organization"
                    });
                    course_service.sendToOrgPage(context);
                  }),
                  ScholarlyButton("Join an existing organization",
                      onPressed: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
