
import 'package:dev_releases/src/helper/constants.dart';
import 'package:dev_releases/src/screens/add_tech_screen.dart';
import 'package:dev_releases/src/screens/home_screen.dart';
import 'package:dev_releases/src/screens/settings_screen.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  final List<String> favTechIdsStringList;

  App({this.favTechIdsStringList});

  @override
  _AppState createState() => _AppState(
      favTechIdsStringList: favTechIdsStringList,
  );

}

class _AppState extends State<App> {

  final List<String> favTechIdsStringList;

  _AppState({this.favTechIdsStringList});



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
        title: Constants.appTitle,
        home: _defaultScreen,
        routes: <String, WidgetBuilder>{
          // Set routes for using the Navigator.
          '/home': (BuildContext context) => new HomeScreen(favTechIdsStringList),
          '/settings': (BuildContext context) => new SettingsScreen(),
          '/addTech': (BuildContext context) => new AddTechScreen()
        });
  }
}