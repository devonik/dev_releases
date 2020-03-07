
import 'package:dev_releases/src/App.dart';
import 'package:dev_releases/src/service/tech_service.dart';
import 'package:flutter/material.dart';


void main() async {


  WidgetsFlutterBinding.ensureInitialized();
  final List<String> favTechIdsStringList = await fetchLocalTechs();
  final App app = App(
      favTechIdsStringList: favTechIdsStringList
  );
  runApp(app);
}