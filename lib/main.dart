
import 'package:dev_releases/src/App.dart';
import 'package:dev_releases/src/service/tech_service.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<String> localTechs = await fetchLocalTechs();
  final App app = App(
    localTechs: localTechs
  );
  runApp(app);
}