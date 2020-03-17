

import 'dart:ffi';

import 'package:dev_releases/src/helper/global_widgets.dart';
import 'package:dev_releases/src/helper/screen_arguments.dart';
import 'package:dev_releases/src/models/add_tech_response.dart';
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
  List<String> _favTechIdsStringList = [];
  GithubRepo _githubRepoSelected;
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
      final TechScreenArguments args = route.settings.arguments;
      //Args are null if the screen is not called by the action button
      if(args != null){
        if(args.favTechIdsStringList.length > 0){
          _favTechIdsStringList = args.favTechIdsStringList;
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
          onPressed: null,
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

  void _filterGithubRepos(String query) {

    if(query.isNotEmpty) {
      if (_githubRepoList.length <= 0) {
        //If the list is empty we have to call the api to set our list
        if(query.length >= 7) {
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

  Widget _buildRepoListItem(GithubRepo githubRepo){
    return ListTile(
      title: Text(
        githubRepo.displayName,
        style: _biggerFont,
      ),
      trailing: Text('Tab to add'),
      onTap: () {
        _showConfirmDialog(githubRepo);
      },
    );
  }

  Future<void> _showConfirmDialog(GithubRepo githubRepoSelected) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Youre going to add ['+githubRepoSelected.displayName+'] to our database\n'),
                  Text('After doing this it will be automatically added to your dashboard'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Nah. I don't want this"),
                color: Colors.redAccent,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Let's do this"),
                color: Colors.green,
                onPressed: () {
                  _githubRepoSelected = githubRepoSelected;
                  _addTechToRemote();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
          }
    );
  }

  Future<void> _showErrorDialog(AddTechResponse addTechResponse) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Icon(Icons.error),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Sorry. The repository could not be added. Try another one\n'),
                  Text(
                      'Error message: ',
                      style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  Text(
                      addTechResponse.error,
                      style: TextStyle(color: Colors.redAccent)
                  )
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
    );
  }

  void _addTechToRemote() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    pr.show();
    prefs.setStringList('techs', _favTechIdsStringList);
    addTech(_githubRepoSelected).then((response){
      pr.hide();
      if(response.error == null){
        //Successfully added the tech to remote
        Tech newTech = Tech.fromJson(response.tech);
        //Lets do the following things

        //1. Add the entry to our local sqlite database
        techRepository.insertTech(newTech).then((response){
          //2. If we add the tech to our sqlite lets add the id to our shared preference
          _favTechIdsStringList.add(newTech.id.toString());
          prefs.setStringList('techs', _favTechIdsStringList);

          //3. Lets go back to home
          Navigator.pushReplacementNamed(context, "/home", arguments: TechScreenArguments(_favTechIdsStringList, false));
        });
      }else{
          //If there was an error lets display it
          _showErrorDialog(response);
      }
      //pr.hide();
    });
  }

}

