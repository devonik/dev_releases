import 'dart:convert';
import 'dart:io';
import 'package:dev_releases/src/helper/constants.dart';
import 'package:dev_releases/src/models/add_tech_response.dart';
import 'package:dev_releases/src/models/github_repo_model.dart';
import 'package:dev_releases/src/models/tech_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dev_releases/src/models/tech_model.dart';

Future<bool> sendBugReport(Tech tech, String bugType, String customText) async {
  final http.Response response = await http.post(
    Constants.backendUrl+'/api/report/sendBugReport',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'tech': tech.toMap(),
      'bugType': bugType,
      'customText': customText
    }),
  );
  if (response.statusCode == 200) {
    // If the server did return a 200 CREATED response,
    // then parse the JSON.
    return true;
  } else {
    // If the server did not return a 200 CREATED response,
    // then throw an exception.
    throw Exception('Failed to send bug report. Response: '+response.body);
  }
}