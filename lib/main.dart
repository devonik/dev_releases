
import 'dart:async';
import 'package:dev_releases/src/App.dart';
import 'package:dev_releases/src/service/tech_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';


void main() async {
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  WidgetsFlutterBinding.ensureInitialized();
  final List<String> favTechIdsStringList = await fetchLocalTechs();
  final App app = App(
      favTechIdsStringList: favTechIdsStringList
  );

  runZoned(() {
    runApp(app);
  }, onError: Crashlytics.instance.recordError);
}