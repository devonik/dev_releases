
import 'package:dev_releases/src/screens/home_screen.dart';
import 'package:dev_releases/src/screens/settings_screen.dart';
import 'package:dev_releases/src/service/tech_service.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App extends AppMVC {
  static MaterialApp _app;
  static String get title => _app.title.toString();


  @override
  Widget build(BuildContext context) {

    _app = MaterialApp(
      title: 'mvc example',
      home: HomeScreen([]),
      routes: <String, WidgetBuilder>{
        // Set routes for using the Navigator.
        '/home': (BuildContext context) => new HomeScreen([]),
        '/settings': (BuildContext context) => new SettingsScreen()
      }
    );
    return _app;
  }

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {

  Future<List<String>> _localTechs = fetchLocalTechs();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _localTechs, // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        List<Widget> children;

        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return MaterialApp(
                title: 'mvc example',
                home: HomeScreen(snapshot.data),
                routes: <String, WidgetBuilder>{
                  // Set routes for using the Navigator.
                  '/home': (BuildContext context) => new HomeScreen(snapshot.data),
                  '/settings': (BuildContext context) => new SettingsScreen()
                }
            );
          }
        } else if (snapshot.hasError) {
          children = <Widget>[
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Error: ${snapshot.error}'),
            )
          ];
        } else {
          children = <Widget>[
            SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Awaiting result...'),
            )
          ];
        }
        //If the local techs are not there atm display the settings page instead
        return SettingsScreen();
      },
    );
  }
}