import 'dart:io';

import 'package:dev_releases/src/helper/constants.dart';
import 'package:dev_releases/src/screens/add_tech_screen.dart';
import 'package:dev_releases/src/screens/home_screen.dart';
import 'package:dev_releases/src/screens/settings_screen.dart';
import 'package:dev_releases/src/service/shared_preferences_service.dart';
import 'package:dev_releases/src/widgets/progress_dialog_widget.dart';
import 'package:flutter/material.dart';
//import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';



class App extends StatefulWidget {
  final List<String> favTechIdsStringList;

  App({this.favTechIdsStringList});

  @override
  _AppState createState() =>
      _AppState(
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
    if (Platform.isAndroid) {
      //Cannot persist it wait for https://github.com/Norbert515/dynamic_theme/issues/43
      fetchIsDark().then((isDark) {
        if (isDark) {
          FlutterStatusbarcolor.setNavigationBarColor(Colors.black);
        } else {
          FlutterStatusbarcolor.setNavigationBarColor(Colors.blueGrey);
        }
      });
    }
    return new MaterialApp(
        title: Constants.appTitle,
        theme: new ThemeData(
            primarySwatch: Colors.blueGrey,
            brightness: Brightness.light,
            fontFamily: 'Hind',
            // Define the default TextTheme. Use this to specify the default
            // text styling for headlines, titles, bodies of text, and more.
            textTheme: TextTheme(
              headline5: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
              headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
              bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
            )),
        home: _defaultScreen,
        routes: <String, WidgetBuilder>{
          // Set routes for using the Navigator.
          '/home': (BuildContext context) =>
          new HomeScreen(favTechIdsStringList),
          '/settings': (BuildContext context) => new SettingsScreen(),
          '/addTech': (BuildContext context) => new AddTechScreen()
        });
  }
    //FlutterStatusbarcolor.setNavigationBarColor(Theme.of(context).brightness == Brightness.dark ? Brightness.light: Brightness.dark);
    //TODO dynamic theme does not work yet - error : The method 'ancestorStateOfType' isn't defined for the class 'BuildContext'.
    /*return new DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => new ThemeData(
          primarySwatch: Colors.blueGrey,
          brightness: brightness,
          fontFamily: 'Hind',
          // Define the default TextTheme. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
          textTheme: TextTheme(
            headline5: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          ),
        ),
        themedWidgetBuilder: (context, theme) {
          return new MaterialApp(
              title: Constants.appTitle,
              theme: theme,
              home: _defaultScreen,
              routes: <String, WidgetBuilder>{
                // Set routes for using the Navigator.
                '/home': (BuildContext context) =>
                new HomeScreen(favTechIdsStringList),
                '/settings': (BuildContext context) => new SettingsScreen(),
                '/addTech': (BuildContext context) => new AddTechScreen()
              });
        }
    );
  }
  }*/
}