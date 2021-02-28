import 'package:cached_network_image/cached_network_image.dart';
import 'package:dev_releases/src/helper/constants.dart';
import 'package:dev_releases/src/helper/global_widgets.dart';
import 'package:dev_releases/src/helper/screen_arguments.dart';
import 'package:dev_releases/src/models/tech_model.dart';
import 'package:dev_releases/src/repository/tech_repository.dart';
import 'package:dev_releases/src/screens/tech_detail_screen.dart';

import 'package:dev_releases/src/service/tech_service.dart';
import 'package:dev_releases/src/widgets/app_bar_add_tech_button.dart';
import 'package:dev_releases/src/widgets/app_bar_setting_button.dart';
import 'package:dev_releases/src/widgets/fit_in_space_text_widget.dart';

//import 'package:dynamic_theme/dynamic_theme.dart';
//import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


class HomeScreen extends StatefulWidget {
  final List<String> favTechIdsStringList;

  HomeScreen(this.favTechIdsStringList);

  @override
  State<HomeScreen> createState() => HomeView(favTechIdsStringList);
}

class HomeView extends State<HomeScreen> {
  RefreshController _refreshController;

  HomeView(this.favTechIdsStringList);

  TechRepository techRepository = new TechRepository();

  List<String> favTechIdsStringList;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
  }

  //Pull to refresh
  //Comes from header
  void _onRefresh() async {
    // monitor network fetch
    fetchTechsByIdStringList(favTechIdsStringList).then((response) {
      if (response != null) {
        techRepository.insertOrUpdateTechList(response).then((response) {
          setState(() {});
          _refreshController.refreshCompleted();
        });
      }
    });
  }

  //Pull to refresh
  //Comes from footer
  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    // Extract the arguments from the current ModalRoute settings and cast
    // them as ScreenArguments.
    var route = ModalRoute.of(context);
    //Avoid null exception if the screen is not called by navigator
    if (route != null) {
      final TechScreenArguments args = route.settings.arguments;
      if (args != null) {
        //Args are null if the screen is not called by the action button
        if (args.favTechIdsStringList.length > 0) {
          favTechIdsStringList = args.favTechIdsStringList;
          //Update UI
          this.setState(() {});
        }
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(Constants.appTitle),
          actions: <Widget>[
            /*IconButton(
                icon: Icon(Icons.colorize),
                onPressed: () {
                  //Test crashlytics firebase report
                  _changeBrightness(context);
                }),*/
            AddTechButtonWidget(
              favTechIdsStringList: favTechIdsStringList,
              callback: (favList) => setState(() {
                favTechIdsStringList = favList;
              }),
            ),
            SettingButtonWidget(
              favTechIdsStringList: favTechIdsStringList,
              callback: (favList) => setState(() {
                favTechIdsStringList = favList;
              }),
            ),
          ],
        ),
        body: _buildGrid(favTechIdsStringList));
  }

  /*void _changeBrightness(BuildContext context) {
    DynamicTheme.of(context).setBrightness(
        Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark);
    FlutterStatusbarcolor.setNavigationBarColor(
        Theme.of(context).brightness == Brightness.dark
            ? Colors.blueGrey
            : Colors.black);
  }*/

  Widget _buildGrid(List<String> favTechIdsStringList) {
    return FutureBuilder<List<Tech>>(
        future: techRepository.getByIds(favTechIdsStringList.join(",")),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                header: WaterDropMaterialHeader(),
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    padding: const EdgeInsets.all(8),
                    childAspectRatio: 1,
                    children: snapshot.data.map<Widget>((tech) {
                      return _GridListTechItem(tech: tech);
                    }).toList()));
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return buildRiveLoadingCircle();
        });
  }
}

class _GridListTechItem extends StatelessWidget {
  _GridListTechItem({Key key, @required this.tech}) : super(key: key);

  final Tech tech;

  @override
  Widget build(BuildContext context) {
    DateTime _techParsedPublishedAt = DateTime.parse(tech.releasePublishedAt);
    var _formatter = new DateFormat('dd.MM.yyyy');
    String _techPublishedAtString = _formatter.format(_techParsedPublishedAt);

    final Widget image = Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      clipBehavior: Clip.antiAlias,
      child: tech.heroImage != null
          ? CachedNetworkImage(
              imageUrl: tech.heroImage,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.scaleDown),
                ),
              ),
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            )
          : Image.asset('assets/icon/fancy_github.png'),
    );
    //OLD WAY: Done with cache_network_image. But there were an error
    /*tech.heroImage != null ? CachedNetworkImage(
        imageUrl: tech.heroImage,
        placeholder: (context, url) => buildRiveLoadingCircle(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ) : Image.asset('assets/icon/fancy_github.png'),*/
    return GridTile(
      child: new InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TechDetailScreen(tech: tech)));
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
            title: FitInSpaceTextWidget(tech.title),
            subtitle: FitInSpaceTextWidget("Made by " +
                tech.githubOwner +
                "\n" +
                tech.latestTag +
                " (" +
                _techPublishedAtString +
                ")")),
      ),
    );
  }
}
