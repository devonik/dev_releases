import 'dart:convert';
import 'package:dev_releases/src/helper/constants.dart';
import 'package:dev_releases/src/models/add_tech_response.dart';
import 'package:dev_releases/src/models/github_repo_model.dart';
import 'package:dev_releases/src/models/tech_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;


Future<List<Tech>> fetchTechs() async {
  final response = await http.get(Constants.backendUrl+'/api/tech/getAll');

  // If the server did return a 200 OK response, then parse the JSON.
  if (response.statusCode == 200) {
    // Use the compute function to run parsePhotos in a separate isolate.
    return compute(parseTechs, response.body);
  } else {
    // If the server did not return a 200 OK response, then throw an exception.
    throw Exception('Failed to load techs');
  }
}

// A function that converts a response body into a List<Photo>.
List<Tech> parseTechs(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Tech>((json) => Tech.fromJson(json)).toList();
}

Future<AddTechResponse> addTech(GithubRepo githubRepo) async {
  final http.Response response = await http.post(
    Constants.backendUrl+'/api/tech/add',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'ownerName': githubRepo.ownerName,
      'repoName': githubRepo.repoName
    }),
  );
  if (response.statusCode == 200) {
    // If the server did return a 200 CREATED response,
    // then parse the JSON.
    return AddTechResponse.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 CREATED response,
    // then throw an exception.
    throw Exception('Failed to add tech');
  }
}





