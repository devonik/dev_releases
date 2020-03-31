import 'dart:io';

import 'package:dev_releases/src/helper/screen_arguments.dart';
import 'package:dev_releases/src/models/tech_model.dart';
import 'package:dev_releases/src/repository/tech_repository.dart';
import 'package:dev_releases/src/service/tech_service.dart';
import 'package:dev_releases/src/widgets/app_bar_report_menu.dart';
import 'package:dev_releases/src/widgets/image_picker_widget.dart';
import 'package:dev_releases/src/widgets/progress_dialog_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:dev_releases/src/widgets/progress_dialog_widget.dart';
import 'package:url_launcher/url_launcher.dart';


class TechDetailScreen extends StatelessWidget{
  final List<String> favTechIdsStringList;
  final Tech tech;

  // In the constructor, require a Tech.
  TechDetailScreen({Key key, @required this.tech, @required this.favTechIdsStringList}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tech.title),
        actions: <Widget>[
          tech.heroImage == null ? Builder(
            builder: (BuildContext context) {
              return ImagePickerWidget(callback: (selectedImage) {
                _uploadRepoImage(context, selectedImage, tech);
              });
            },
          ) : Container(),
          IconButton(
              icon: Icon(FontAwesome.github),
              onPressed: () {
                launch(tech.githubLink);
              }
          ),
          ReportMenu(tech: tech)
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Markdown(data: tech.body)
      ),
    );
  }

  void _uploadRepoImage(BuildContext context, File image, Tech tech){
    TechRepository techRepository = new TechRepository();
    ProgressDialog pr = new ProgressDialogWidget().init(context);
    pr.style(message: "Uploading...");
    pr.show();
    addImageToTech(image, tech).then((response){
      techRepository.updateTech(response).then((value){
        pr.hide();
        String snackBarText = "Thanks for adding image to ["+tech.githubOwner+"/"+tech.githubRepo+"]";
        displaySnackBar(context, snackBarText);
      });
    });
  }

  void displaySnackBar(BuildContext context, String snackBarText){
    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(snackBarText)));
  }
}