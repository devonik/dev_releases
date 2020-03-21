

import 'package:dev_releases/src/helper/global_widgets.dart';
import 'package:dev_releases/src/helper/screen_arguments.dart';
import 'package:dev_releases/src/models/tech_model.dart';
import 'package:dev_releases/src/repository/tech_repository.dart';
import 'package:dev_releases/src/service/firebase_messaging_service.dart';
import 'package:dev_releases/src/service/shared_preferences_service.dart';
import 'package:dev_releases/src/service/tech_service.dart';
import 'package:dev_releases/src/widgets/progress_dialog_widget.dart';
import 'package:dev_releases/src/widgets/settings_save_button.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SettingsScreen extends StatefulWidget {
  @protected
  @override
  State<SettingsScreen> createState() => SettingsView();
}

class SettingsView extends State<SettingsScreen> {
  ProgressDialog pr;
  List<String> _favTechIdsStringList = [];
  List<Tech> _remoteTechData = new List();
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
  bool _isScreenCalledByNavigator = false;


  @override
  void initState() {
    super.initState();
    pr = new ProgressDialogWidget().init(context);
  }

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
      return buildRiveLoadingCircle();

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
          String techIdString = tech.id.toString();
          if (isTechFavorite) {
            _favTechIdsStringList.remove(techIdString);
            //Unsubscribe from topic so wo don't get any push notification for this
            firebaseMessagingUnSubscribe('new-release-'+techIdString);
            print("unsubscibe: "+'new-release-'+techIdString);
          } else {
            _favTechIdsStringList.add(techIdString);
            //Unsubscribe from topic so wo don't get any push notification for this
            firebaseMessagingSubscribe('new-release-'+techIdString);
            print("subscibe: "+'new-release-'+techIdString);
          }
        });
      },
    );
  }
  // #enddocregion _buildRow

  // #docregion RWS-build
  @override
  Widget build(BuildContext context) {

    //pr = new ProgressDialog(context);
    // Extract the arguments from the current ModalRoute settings and cast
    // them as ScreenArguments.
    var route = ModalRoute.of(context);
    //Avoid null exception if the screen is not called by navigator
    if(route!=null){
      final TechScreenArguments args = route.settings.arguments;
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
      floatingActionButton: SaveSettingsButtonWidget(
        favTechIdsStringList: _favTechIdsStringList,
        remoteTechData: _remoteTechData,
        callback: (finish) {
          print("Setting saving finished: " + finish.toString());
          _navigateToHome();
        },
      )
    );
  }


  void _navigateToHome(){
    if(_isScreenCalledByNavigator){
      //Navigator.popUntil(context, ModalRoute.withName('/home'));
      //If we called this screen by a navigator route (as example the button on home) we want to go back to home
      Navigator.pop(context, TechScreenArguments(_favTechIdsStringList, false, 'Saved settings'));
    }else{
      //If we called this screen not by navigator (first screen if there no techs saved on local storage) we want to go to home without a navigation route (without back button)
      Navigator.pushReplacementNamed(context, "/home", arguments: TechScreenArguments(_favTechIdsStringList, false, 'Saved settings'));
    }
  }
}
