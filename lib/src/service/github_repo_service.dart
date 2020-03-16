import 'package:dev_releases/src/models/github_repo_model.dart';
import 'dart:convert';
import 'package:dev_releases/src/helper/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<List<GithubRepo>> fetchGithubRepos(String name) async {
  final response = await http.get(Constants.githubApiUrl+'/search/repositories?q='+name+'+in:name&sort=stars&order=desc');

  // If the server did return a 200 OK response, then parse the JSON.
  if (response.statusCode == 200) {
    // Use the compute function to run parsePhotos in a separate isolate.
    return compute(parseGithubRepos, response.body);
  } else {
    // If the server did not return a 200 OK response, then throw an exception.
    throw Exception('Failed to load album');
  }
}

// A function that converts a response body into a List<GithubRepo>.
List<GithubRepo> parseGithubRepos(String responseBody) {
  final parsedItems = json.decode(responseBody)['items'].cast<Map<String, dynamic>>();;

  return parsedItems.map<GithubRepo>((json) => GithubRepo.fromJson(json)).toList();
}