

import 'dart:ffi';

import 'package:dev_releases/src/helper/global_widgets.dart';
import 'package:dev_releases/src/models/github_repo_model.dart';
import 'package:dev_releases/src/models/tech_model.dart';
import 'package:dev_releases/src/repository/tech_repository.dart';
import 'package:dev_releases/src/service/github_repo_service.dart';
import 'package:dev_releases/src/service/tech_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_dialog/progress_dialog.dart';


class AddTechScreen extends StatefulWidget {
  @protected
  @override
  State<AddTechScreen> createState() => AddTechView();
}

class AddTechView extends State<AddTechScreen> {
  ProgressDialog pr;
  List<Tech> _favTechList = [];
  List<GithubRepo> _githubRepoSelected = [];
  List<GithubRepo> _githubRepoList = [];
  //GithubRepo _placeholderRepoList = new GithubRepo(displayName: "Type 3 characters to search");

  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
  final TechRepository techRepository = new TechRepository();


  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);
    pr.style(
        message: 'Search...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: buildRiveLoadingCircle(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
    );

    // Extract the arguments from the current ModalRoute settings and cast
    // them as ScreenArguments.
    var route = ModalRoute.of(context);
    //Avoid null exception if the screen is not called by navigator
    if(route!=null){
      final AddTechScreenArguments args = route.settings.arguments;
      //Args are null if the screen is not called by the action button
      if(args != null){
        if(args.favTechList.length > 0){
          _favTechList = args.favTechList;
        }
      }

    }

  return Scaffold(
      appBar: AppBar(
        title: Text('Add your favorite github repository'),
      ),
      body: _buildRepoDropdown(),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.save),
          onPressed: _pushSaved,
          tooltip: "Save"
      ),
    );
  }

  TextEditingController searchEditingController = TextEditingController();
  Widget _buildRepoDropdown(){
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                _filterGithubRepos(value);
              },
              controller: searchEditingController,
              decoration: InputDecoration(
                  labelText: "Search",
                  hintText: "Search (at least 3 character)",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _githubRepoList.length,
              itemBuilder: (context, index) {
                return _buildRepoListItem(_githubRepoList.elementAt(index));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepoListItem(GithubRepo githubRepo){
    bool isRepoSelected = _githubRepoSelected.contains(githubRepo);
    return ListTile(
      title: Text(
        githubRepo.displayName,
        style: _biggerFont,
      ),
      trailing: Icon(   // Add the lines from here...
        isRepoSelected ? Icons.favorite : Icons.favorite_border,
        color: isRepoSelected ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (isRepoSelected) {
            _githubRepoSelected.remove(githubRepo);
          } else {
            _githubRepoSelected.add(githubRepo);
          }
        });
      },
    );
  }

  void _filterGithubRepos(String query) {

    if(query.isNotEmpty) {
      if (_githubRepoList.length <= 0) {
        //If the list is empty we have to call the api to set our list
        if(query.length >= 3) {
          //Only query if query has minimum 3 character
          pr.show();
          fetchGithubRepos(query).then((result) {
            if (result != null) {
              setState(() {
                _githubRepoList = result;
                pr.hide();
              });
            }
          });
        }
      } else {
        //We already request the github api so we have a list to filter local
        List<GithubRepo> _filteredGithubRepoList = List<GithubRepo>();
        _githubRepoList.forEach((repo) {
          if (repo.displayName.contains(query)) {
            _filteredGithubRepoList.add(repo);
          }
        });
        //The query is empty
        setState(() {
          _githubRepoList.clear();
          _githubRepoList.addAll(_filteredGithubRepoList);
        });
      }
    }else{
      //The query is empty
      setState(() {
        _githubRepoList.clear();
      });
    }

  }

  void _pushSaved() async {
    //Todo send the selected repos to backend and get the entries back
    /*for(int i = 0; i < _favTechIdsStringList.length; i++){
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
    //Todo save the entries in our sqlite database
    //Todo Also add the ids to our shared preference

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('techs', _favTechIdsStringList);

    if(_isScreenCalledByNavigator){
      //If we called this screen by a navigator route (as example the button on home) we want to go back to home
      Navigator.pop(context, _favTechIdsStringList);
    }else{
      //If we called this screen not by navigator (first screen if there no techs saved on local storage) we want to go to home without a navigation route (without back button)
      Navigator.pushReplacementNamed(context, "/home", arguments: SettingsScreenArguments(_favTechIdsStringList, false));
    }*/

  }

}

// You can pass any object to the arguments parameter.
// In this example, create a class that contains a customizable
// title and message.
class AddTechScreenArguments {
  final List<Tech> favTechList;

  AddTechScreenArguments(this.favTechList);
}
