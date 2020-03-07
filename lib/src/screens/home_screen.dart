import 'package:dev_releases/src/models/tech_model.dart';
import 'package:dev_releases/src/repository/tech_repository.dart';
import 'package:dev_releases/src/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';


class HomeScreen extends StatefulWidget {

  final List<String> favTechIdsStringList;

  HomeScreen(this.favTechIdsStringList);

  @override
  State<HomeScreen> createState() => HomeView(favTechIdsStringList);
}

class HomeView extends State<HomeScreen> {
  HomeView(this.favTechIdsStringList);

  TechRepository techRepository = new TechRepository();

  List<String> favTechIdsStringList;


  List<Tech> dbTechList = [];


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
            actions: <Widget>[      // Add 3 lines from here...
              IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    _navigateToSettingsAndSaveData(context);
                  }
              ),
            ],
          ),
          body: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.all(8),
            childAspectRatio: 1,
            children: favTechIdsStringList.map<Widget>((tech){
            return FutureBuilder<Tech>(
              future: techRepository.getById(int.parse(tech)),
              builder: (context, snapshot) {
              if (snapshot.hasData) {

                return _GridListTechItem(
                  tech: snapshot.data
                );

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
            }).toList(),
          ),
      );
    }
  _navigateToSettingsAndSaveData(BuildContext context) async{
    final result = await Navigator.pushNamed(context, '/settings', arguments: SettingsScreenArguments(favTechIdsStringList, true));

    favTechIdsStringList = result;
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
    final Widget image = Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
         tech.heroImage
      ),
    );

    return GridTile(
      footer: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
        ),
        clipBehavior: Clip.antiAlias,
        child: GridTileBar(
          backgroundColor: Colors.black45,
          title: _GridTitleText(tech.title),
          subtitle: _GridTitleText(tech.latestTag),
        ),
      ),
      child: image,
    );
  }
}
