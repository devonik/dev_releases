

import 'package:dev_releases/src/models/tech_model.dart';
import 'package:dev_releases/src/service/tech_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flare_flutter/flare_actor.dart';


class SettingsScreen extends StatefulWidget {
  //bool settingsDone = false;
  @protected
  @override
  State<SettingsScreen> createState() => SettingsView();
}

class SettingsView extends State<SettingsScreen> {
  List<String> _savedTechs = [];
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
  bool _isScreenCalledByNavigator = false;

  Widget _buildSuggestions() {
    return FutureBuilder<List<Tech>>(
      future: fetchTechs(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {

          return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemBuilder: /*1*/ (context, i) {

                return _buildRow(snapshot.data[i]);
              });
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner.
        //return CircularProgressIndicator();
      return Center(
          child: FlareActor("assets/animations/CircularProgressIndicator.flr",
              animation: "Loading",
              color: Colors.blueGrey
          ),
        );

      },
    );

  }
  // #enddocregion _buildSuggestions

  // #docregion _buildRow
  Widget _buildRow(Tech tech) {
    bool isTechFavorite = _savedTechs.contains(tech.title);
    return ListTile(
      title: Text(
        tech.title,
        style: _biggerFont,
      ),
      trailing: Icon(   // Add the lines from here...
        isTechFavorite ? Icons.favorite : Icons.favorite_border,
        color: isTechFavorite ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (isTechFavorite) {
            _savedTechs.remove(tech.title);
          } else {
            _savedTechs.add(tech.title);
          }
        });
      },
    );
  }
  // #enddocregion _buildRow

  // #docregion RWS-build
  @override
  Widget build(BuildContext context) {

    // Extract the arguments from the current ModalRoute settings and cast
    // them as ScreenArguments.
    var route = ModalRoute.of(context);
    //Avoid null exception if the screen is not called by navigator
    if(route!=null){
      final SettingsScreenArguments args = route.settings.arguments;
      if(args != null){
        //Args are null if the screen is not called by the action button
        if(args.localTechs.length > 0){
          _savedTechs = args.localTechs;
          _isScreenCalledByNavigator = args.isScreenCalledByNavigator;
        }
      }

    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Choose youre favorite tools'),
      ),
      body: _buildSuggestions(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: _pushSaved,
        tooltip: "Save"
      ),
    );
  }
  void _pushSaved() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Add to favorite techs

    //prefs.remove('techs');
    prefs.setStringList('techs', _savedTechs);

    if(_isScreenCalledByNavigator){
      //If we called this screen by a navigator route (as example the button on home) we want to go back to home
      Navigator.pop(context);
    }else{
      //If we called this screen not by navigator (first screen if there no techs saved on local storage) we want to go to home without a navigation route (without back button)
      Navigator.pushReplacementNamed(context, "/home", arguments: SettingsScreenArguments(_savedTechs, false));
    }

  }

}

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.
class SettingsScreenArguments {
  final List<String> localTechs;
  final bool isScreenCalledByNavigator;

  SettingsScreenArguments(this.localTechs, this.isScreenCalledByNavigator);
}
