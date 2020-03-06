import 'package:dev_releases/src/service/tech_service.dart';
import 'package:dev_releases/src/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {

  List<String> localTechs = [];

  HomeScreen(List<String> localTechs){
    this.localTechs = localTechs;
  }

  @override
  State<HomeScreen> createState() => HomeView(localTechs);
}

class HomeView extends State<HomeScreen> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  List<String> localTechs = [];

  HomeView(List<String> localTechs){
    this.localTechs = localTechs;
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            title: Text('Startup Name Generator'),
            actions: <Widget>[      // Add 3 lines from here...
              IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings', arguments: SettingsScreenArguments(localTechs));
                  }
              ),
            ],
          ),
          body: Center(
              child: Text('Button tapped $_counter time${ _counter == 1 ? '' : 's' }.')
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Increment',
              child: Icon(Icons.add)
          )
      );
    }

}