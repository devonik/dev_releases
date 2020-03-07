import 'dart:convert';
import 'package:dev_releases/helper/constants.dart';
import 'package:dev_releases/src/models/tech_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';


Future<List<Tech>> fetchTechs() async {
  final response = await http.get(Constants.BACKEND_URL+'/api/tech/getAll');

  // If the server did return a 200 OK response, then parse the JSON.
  if (response.statusCode == 200) {
    // Use the compute function to run parsePhotos in a separate isolate.
    return compute(parseTechs, response.body);
  } else {
    // If the server did not return a 200 OK response, then throw an exception.
    throw Exception('Failed to load album');
  }
}

// A function that converts a response body into a List<Photo>.
List<Tech> parseTechs(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Tech>((json) => Tech.fromJson(json)).toList();
}

Future<List<String>> fetchLocalTechs() async{
  final prefs = await SharedPreferences.getInstance();
  //Add to favorite techs
  return prefs.getStringList('techs');

}




