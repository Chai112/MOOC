import 'package:flutter/material.dart';
import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:mooc/services/networking_service.dart' as networking_service;

Future<int?> getFirstOrganizationId() async {
  String token = auth_service.globalUser.token!.token;

  Map<String, dynamic> response =
      await networking_service.getServer("getOrganizationsFromUser", {
    "token": token,
  });
  // bring to create a new organization
  if (response["data"].length != 0) {
    String organizationId = response["data"][0]["organizationId"].toString();
    return int.parse(organizationId);
  } else {
    // user does not have any organizations
    return null;
  }
}

void sendToOrgPage(BuildContext context, {int? organizationId}) async {
  // if organizationId not given, user wants to find first organization
  if (organizationId == null) {
    String token = auth_service.globalUser.token!.token;

    Map<String, dynamic> response =
        await networking_service.getServer("getOrganizationsFromUser", {
      "token": token,
    });
    // bring to create a new organization
    if (response["data"].length == 0) {
      // user does not have any organizations
      Navigator.of(context).pushNamed("/organization-register");
      return;
    } else {
      organizationId = response["data"][0]["organizationId"];
    }
    // find first organizationId, if user has no organization, then go to register
  }
  Navigator.of(context).pushNamed("/organization?id=$organizationId");
}

void sendToCoursePage(BuildContext context,
    {int? courseId, int? organizationId}) async {
  // if courseId not given, user wants to create a new course
  if (courseId == null) {
    String token = auth_service.globalUser.token!.token;

    if (organizationId == null) {
      throw Exception("invalid use of function");
    }
    Map<String, dynamic> response =
        await networking_service.getServer("createCourse", {
      "token": token,
      "organizationId": organizationId.toString(),
      "courseName": "Untitled",
    });
    courseId = response["courseId"];
    // create new course
  }
  Navigator.of(context).pushNamed("/course?id=$courseId");
}
