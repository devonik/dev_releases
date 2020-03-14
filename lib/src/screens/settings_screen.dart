

import 'package:dev_releases/src/models/tech_model.dart';
import 'package:dev_releases/src/repository/tech_repository.dart';
import 'package:dev_releases/src/service/tech_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flare_flutter/flare_actor.dart';


class SettingsScreen extends StatefulWidget {
  @protected
  @override
  State<SettingsScreen> createState() => SettingsView();
}

class SettingsView extends State<SettingsScreen> {
  List<String> _favTechIdsStringList = [];
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
  bool _isScreenCalledByNavigator = false;
  final TechRepository techRepository = new TechRepository();
  List<Tech> _remoteTechData;

  Widget _buildSuggestions() {
    return FutureBuilder<List<Tech>>(
      future: fetchTechs(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _remoteTechData = snapshot.data;
          return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data.length,
              itemBuilder: (context, i) {

                return _buildRow(snapshot.data.elementAt(i));
              });
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
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
    bool isTechFavorite = _favTechIdsStringList.contains(tech.id.toString());
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
            _favTechIdsStringList.remove(tech.id.toString());
          } else {
            _favTechIdsStringList.add(tech.id.toString());
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
      //Args are null if the screen is not called by the action button
      if(args != null){
        _isScreenCalledByNavigator = args.isScreenCalledByNavigator;
        if(args.favTechIdsStringList.length > 0){
          _favTechIdsStringList = args.favTechIdsStringList;
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
    for(int i = 0; i < _favTechIdsStringList.length; i++){
      int id = int.parse(_favTechIdsStringList[i]);
      techRepository.getById(id).then((value) {
        if(value == null){
          //The item is not in our local database yet - lets save it
          Tech itemToInsert = _remoteTechData.singleWhere((item) => item.id == id);
          techRepository.insertTech(itemToInsert);
        }else{
          //If we have the tech in our database lets update it to latest
          Tech itemToUpdate = _remoteTechData.singleWhere((item) => item.id == id);
          techRepository.updateTech(itemToUpdate);
        }

      });

    }

    prefs.setStringList('techs', _favTechIdsStringList);

    if(_isScreenCalledByNavigator){
      //If we called this screen by a navigator route (as example the button on home) we want to go back to home
      Navigator.pop(context, _favTechIdsStringList);
    }else{
      //If we called this screen not by navigator (first screen if there no techs saved on local storage) we want to go to home without a navigation route (without back button)
      Navigator.pushReplacementNamed(context, "/home", arguments: SettingsScreenArguments(_favTechIdsStringList, false));
    }

  }

}

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.
class SettingsScreenArguments {
  final List<String> favTechIdsStringList;
  final bool isScreenCalledByNavigator;

  SettingsScreenArguments(this.favTechIdsStringList, this.isScreenCalledByNavigator);
}
