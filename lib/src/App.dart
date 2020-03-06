
import 'package:dev_releases/src/screens/home_screen.dart';
import 'package:dev_releases/src/screens/settings_screen.dart';
import 'package:dev_releases/src/service/tech_service.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App extends AppMVC {
  static MaterialApp _app;
  static String get title => _app.title.toString();

  final List<String> localTechs;
  App({this.localTechs});

  @override
  Widget build(BuildContext context) {
    Widget _defaultScreen;
    if(localTechs != null){
      _defaultScreen = localTechs.length > 0 ? new HomeScreen(localTechs) : new SettingsScreen();
    }else{
      //If the app is opened first time we have no local techs
      _defaultScreen = new SettingsScreen();
    }
    return MaterialApp(
        title: 'mvc example',
        home: _defaultScreen,
        routes: <String, WidgetBuilder>{
          // Set routes for using the Navigator.
          '/home': (BuildContext context) => new HomeScreen(localTechs),
          '/settings': (BuildContext context) => new SettingsScreen()
        }
    );
  }

  //@override
  // _AppState createState() => _AppState();


/*class _AppState extends State<App> {

  Future<List<String>> _localTechs = fetchLocalTechs();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _localTechs, // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        List<Widget> children;
        Widget _defaultScreen;
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            _defaultScreen = HomeScreen(snapshot.data);

          }else{
            //If the local techs are not there atm display the settings page instead
            _defaultScreen = SettingsScreen();
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

        return MaterialApp(
            title: 'mvc example',
            home: _defaultScreen,
            routes: <String, WidgetBuilder>{
              // Set routes for using the Navigator.
              '/home': (BuildContext context) => new HomeScreen([]),
              '/settings': (BuildContext context) => new SettingsScreen()
            }
        );
      },
    );
  }*/
}