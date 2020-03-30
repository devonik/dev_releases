import 'package:dev_releases/src/models/tech_model.dart';
import 'package:dev_releases/src/widgets/app_bar_report_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class TechDetailScreen extends StatelessWidget{
  final Tech tech;

  // In the constructor, require a Tech.
  TechDetailScreen({Key key, @required this.tech}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tech.title),
        actions: <Widget>[
          IconButton(
              icon: Icon(FontAwesome.github),
              onPressed: () {
                launch(tech.githubLink);
              }
          ),
          ReportMenu()
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Markdown(data: tech.body)
      ),
    );
  }
}