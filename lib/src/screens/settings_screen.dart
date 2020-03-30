import 'package:dev_releases/src/helper/global_widgets.dart';
import 'package:dev_releases/src/helper/screen_arguments.dart';
import 'package:dev_releases/src/models/tech_model.dart';
import 'package:dev_releases/src/service/firebase_messaging_service.dart';
import 'package:dev_releases/src/service/tech_service.dart';
import 'package:dev_releases/src/widgets/progress_dialog_widget.dart';
import 'package:dev_releases/src/widgets/settings_save_button.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

class SettingsScreen extends StatefulWidget {
  @protected
  @override
  State<SettingsScreen> createState() => SettingsView();
}

class SettingsView extends State<SettingsScreen> {
  ProgressDialog pr;
  List<String> _favTechIdsStringList = [];
  List<Tech> _remoteTechData = new List();
  List<Tech> _filteredRemoteTechDataList = List<Tech>();
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
  bool _isScreenCalledByNavigator = false;

  @override
  void initState() {
    super.initState();
    pr = new ProgressDialogWidget().init(context);
  }

  TextEditingController searchEditingController = TextEditingController();

  Widget _buildSuggestions() {
    if (_remoteTechData.length == 0) {
      fetchTechs().then((response) {
        print("fetching remote techs");
        setState(() {
          _remoteTechData = response;
          _filteredRemoteTechDataList = response;
        });
      });
    }

    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                _filterListView(value);
              },
              controller: searchEditingController,
              decoration: InputDecoration(
                  labelText: "Search",
                  hintText: "Type the repository or owner name",
                  prefixIcon: Icon(Icons.filter_list),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0))),
                  suffixIcon: Icon(Icons.search)),
            ),
          ),
          Expanded(
              child: _remoteTechData.length > 0
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredRemoteTechDataList.length,
                      itemBuilder: (context, index) {
                        return _buildRow(_filteredRemoteTechDataList.elementAt(index));
                      })
                  : buildRiveLoadingCircle())
        ],
      ),
    );
  }

  void _filterListView(String query) {
    List<Tech> dummySearchList = List<Tech>();
    dummySearchList.addAll(_remoteTechData);
    if (query.isNotEmpty) {
      List<Tech> dummyListData = List<Tech>();
      dummySearchList.forEach((repo) {
        if (repo.githubRepo.contains(query) ||
            repo.githubOwner.contains(query)) {
          dummyListData.add(repo);
        }
      });
      //The query is not empty
      setState(() {
        _filteredRemoteTechDataList = dummyListData;
      });
    }else{
      setState(() {
        _filteredRemoteTechDataList = _remoteTechData;
      });
    }
  }
  // #enddocregion _buildSuggestions

  // #docregion _buildRow
  Widget _buildRow(Tech tech) {
    bool isTechFavorite = _favTechIdsStringList.contains(tech.id.toString());
    return ListTile(
      title: Text(
        tech.githubOwner + ' / ' + tech.githubRepo,
        style: _biggerFont,
      ),
      trailing: Icon(
        // Add the lines from here...
        isTechFavorite ? Icons.favorite : Icons.favorite_border,
        color: isTechFavorite ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          String techIdString = tech.id.toString();
          if (isTechFavorite) {
            _favTechIdsStringList.remove(techIdString);
            //Unsubscribe from topic so wo don't get any push notification for this
            firebaseMessagingUnSubscribe('new-release-' + techIdString);
            print("unsubscibe: " + 'new-release-' + techIdString);
          } else {
            _favTechIdsStringList.add(techIdString);
            //Unsubscribe from topic so wo don't get any push notification for this
            firebaseMessagingSubscribe('new-release-' + techIdString);
            print("subscibe: " + 'new-release-' + techIdString);
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
    if (route != null) {
      final TechScreenArguments args = route.settings.arguments;
      //Args are null if the screen is not called by the action button
      if (args != null) {
        _isScreenCalledByNavigator = args.isScreenCalledByNavigator;
        if (args.favTechIdsStringList.length > 0) {
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
        ));
  }

  void _navigateToHome() {
    if (_isScreenCalledByNavigator) {
      //Navigator.popUntil(context, ModalRoute.withName('/home'));
      //If we called this screen by a navigator route (as example the button on home) we want to go back to home
      Navigator.pop(context,
          TechScreenArguments(_favTechIdsStringList, false, 'Saved settings'));
    } else {
      //If we called this screen not by navigator (first screen if there no techs saved on local storage) we want to go to home without a navigation route (without back button)
      Navigator.pushReplacementNamed(context, "/home",
          arguments: TechScreenArguments(
              _favTechIdsStringList, false, 'Saved settings'));
    }
  }
}
