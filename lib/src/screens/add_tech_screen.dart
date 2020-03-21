

import 'dart:ffi';
import 'dart:io';

import 'package:dev_releases/src/helper/global_widgets.dart';
import 'package:dev_releases/src/helper/screen_arguments.dart';
import 'package:dev_releases/src/models/add_tech_response.dart';
import 'package:dev_releases/src/models/github_repo_model.dart';
import 'package:dev_releases/src/models/tech_model.dart';
import 'package:dev_releases/src/repository/tech_repository.dart';
import 'package:dev_releases/src/service/github_repo_service.dart';
import 'package:dev_releases/src/service/tech_service.dart';
import 'package:dev_releases/src/widgets/image_picker_widget.dart';
import 'package:dev_releases/src/widgets/progress_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  void initState() {
    super.initState();
    pr = new ProgressDialogWidget().init(context);
  }

  @override
  Widget build(BuildContext context) {
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
      body: _buildRepoDropdown()
    );
  }

  TextEditingController searchEditingController = TextEditingController();
  String _filterQuery;
  Widget _buildRepoDropdown(){
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                _filterQuery = value;
                _filterGithubRepos(value);
              },
              controller: searchEditingController,
              decoration: InputDecoration(
                  labelText: "Search",
                  hintText: "Type the repository name",
                  prefixIcon: Icon(Icons.filter_list),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0))
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      _initRepoRequest(_filterQuery);
                    },
                  )
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value){
                _initRepoRequest(_filterQuery);
              },
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

  void _initRepoRequest(String query){
    //If the list is empty we have to call the api to set our list
    //if(query.length >= 7) {
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
    //}
  }

  void _filterGithubRepos(String query) {

    if(query.isEmpty){
      //The query is empty
      setState(() {
        _githubRepoList.clear();
      });
    }else{
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

          _showSuccessDialog(newTech);
        });
      }else{
        //If there was an error lets display it
        _showErrorDialog(response);
      }
    });
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

  Future<void> _showSuccessDialog(Tech newTech) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                'Thank you!',
                style: TextStyle(color: Colors.green)
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      "You're awesome\n",
                      style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  Text("Your favorite repository is saved in our database and also on your dashboard.\n"),
                  Text("Pleases also select a image for the repository. It will be displayed on your dashboard. \n"),
                  Text(
                      "If you don't there is only a placeholder\n",
                      style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  ImagePickerWidget(callback: (selectedImage) {
                      Navigator.of(context).pop();
                      _uploadRepoImage(selectedImage, newTech);
                  })
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "I does not have a image :(",
                  style: TextStyle(color: Colors.redAccent),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  navigateToHome('Thanks for adding ['+_githubRepoSelected.displayName+']');
                },
              )
            ],
          );
        }
    );
  }

  void _uploadRepoImage(File image, Tech tech){
    pr.show();
    addImageToTech(image, tech).then((response){
      techRepository.updateTech(response).then((value){
        pr.hide();
        navigateToHome('Thanks for adding ['+_githubRepoSelected.displayName+']');
      });
    });
  }

  void navigateToHome(String snackBarText){
    //3. Lets go back to home
    Navigator.pop(context, TechScreenArguments(_favTechIdsStringList, false, snackBarText));
  }
}

