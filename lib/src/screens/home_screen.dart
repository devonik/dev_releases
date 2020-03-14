import 'package:cached_network_image/cached_network_image.dart';
import 'package:dev_releases/src/helper/global_widgets.dart';
import 'package:dev_releases/src/models/tech_model.dart';
import 'package:dev_releases/src/repository/tech_repository.dart';
import 'package:dev_releases/src/screens/settings_screen.dart';
import 'package:dev_releases/src/screens/tech_detail_screen.dart';
import 'package:dev_releases/src/service/firebase_messaging_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {

  final List<String> favTechIdsStringList;

  HomeScreen(this.favTechIdsStringList);

  @override
  State<HomeScreen> createState() => HomeView(favTechIdsStringList);
}

class HomeView extends State<HomeScreen> {

  String _homeScreenText = "Waiting for token...";
  HomeView(this.favTechIdsStringList);

  TechRepository techRepository = new TechRepository();

  List<String> favTechIdsStringList;

  @override
  void initState() {
    super.initState();
    firebaseMessagingSubscribe('new-tech-release');
    firebaseMessagingConfigure(favTechIdsStringList, this);
  }

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
        if(args.favTechIdsStringList.length > 0){
          favTechIdsStringList = args.favTechIdsStringList;
        }
      }

    }

      return Scaffold(
          appBar: AppBar(
            title: Text('Startup Name Generator'),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    _navigateToSettingsAndSaveData(context);
                  }
              ),
            ],
          ),
          body: _buildGrid()
      );
    }

  Widget _buildGrid() {
    return FutureBuilder<List<Tech>>(
        future: techRepository.getByIds(favTechIdsStringList.join(",")),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                padding: const EdgeInsets.all(8),
                childAspectRatio: 1,
                children: snapshot.data.map<Widget>((tech){
                  return _GridListTechItem(
                      tech: tech
                  );
                }).toList()
            );
          }else if (snapshot.hasError) {

            return Text("${snapshot.error}");
          }
          return buildRiveLoadingCircle();
        }
    );

  }

  _navigateToSettingsAndSaveData(BuildContext context) async{
    final result = await Navigator.pushNamed(context, '/settings', arguments: SettingsScreenArguments(favTechIdsStringList, true));

    if(result != null){
      favTechIdsStringList = result;
      //Reload view
      //this.setState((){});
    }
  }

}
//Allow the text size to shrink to fit in the space
class _GridTitleText extends StatelessWidget {
  const _GridTitleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Text(text),
    );
  }
}

class _GridListTechItem extends StatelessWidget {
  _GridListTechItem({
    Key key,
    @required this.tech
  }) : super(key: key);

  final Tech tech;


  @override
  Widget build(BuildContext context) {
    DateTime _techParsedPublishedAt = DateTime.parse(tech.releasePublishedAt);
    var _formatter = new DateFormat('dd.MM.yyyy');
    String _techPublishedAtString = _formatter.format(_techParsedPublishedAt);

    final Widget image = Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: tech.heroImage,
        placeholder: (context, url) => buildRiveLoadingCircle(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );

    return GridTile(
      child: new InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TechDetailScreen(tech: tech),
            ),
          );
        },
        child: image,
      ),
      footer: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
        ),
        clipBehavior: Clip.antiAlias,
        child: GridTileBar(
          backgroundColor: Colors.black45,
          title: _GridTitleText(tech.title),
          subtitle: _GridTitleText(tech.latestTag + " ("+_techPublishedAtString+")")
        ),
      ),
    );
  }
}
