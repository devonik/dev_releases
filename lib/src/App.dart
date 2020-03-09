
import 'package:dev_releases/src/models/tech_model.dart';
import 'package:dev_releases/src/repository/tech_repository.dart';
import 'package:dev_releases/src/screens/home_screen.dart';
import 'package:dev_releases/src/screens/settings_screen.dart';
import 'package:dev_releases/src/service/firebase_messaging_service.dart';
import 'package:dev_releases/src/service/tech_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App extends StatefulWidget {
  static MaterialApp _app;
  static String get title => _app.title.toString();

  final List<String> favTechIdsStringList;
  App({this.favTechIdsStringList});

  @override
  _AppState createState() => _AppState(
      favTechIdsStringList: favTechIdsStringList
  );

}

class _AppState extends State<App> {
  TechRepository techRepository = new TechRepository();
  String _homeScreenText = "Waiting for token...";
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void fcmSubscribe(String topic) {
    _firebaseMessaging.subscribeToTopic(topic);
  }

  void fcmUnSubscribe(String topic) {
    _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  final List<String> favTechIdsStringList;

  _AppState({this.favTechIdsStringList});

  @override
  void initState() {
    super.initState();
    fcmSubscribe('new-tech-release');
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        Tech tech;
        if (message.containsKey('data')) {
          // Handle data message
          final dynamic data = message['data'];
          if(favTechIdsStringList.contains(data['id'].toString())){
            techRepository.updateTech(Tech.fromJson(data));
            print("Tech id" + data['id'] + "got an update");
          }
        }
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        _homeScreenText = "Push Messaging token: $token";
      });
      print(_homeScreenText);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _defaultScreen;
    if (favTechIdsStringList != null) {
      _defaultScreen = favTechIdsStringList.length > 0
          ? new HomeScreen(favTechIdsStringList)
          : new SettingsScreen();
    } else {
      //If the app is opened first time we have no local techs
      _defaultScreen = new SettingsScreen();
    }
    return MaterialApp(
        title: 'mvc example',
        home: _defaultScreen,
        routes: <String, WidgetBuilder>{
          // Set routes for using the Navigator.
          '/home': (BuildContext context) =>
          new HomeScreen(favTechIdsStringList),
          '/settings': (BuildContext context) => new SettingsScreen()
        });
  }
}