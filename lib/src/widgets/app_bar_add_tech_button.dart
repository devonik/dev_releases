import 'package:cached_network_image/cached_network_image.dart';
import 'package:dev_releases/src/helper/global_widgets.dart';
import 'package:dev_releases/src/helper/screen_arguments.dart';
import 'package:dev_releases/src/models/tech_model.dart';
import 'package:dev_releases/src/repository/tech_repository.dart';
import 'package:dev_releases/src/screens/add_tech_screen.dart';
import 'package:dev_releases/src/screens/settings_screen.dart';
import 'package:dev_releases/src/screens/tech_detail_screen.dart';
import 'package:dev_releases/src/service/firebase_messaging_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef void FavTechListCallback(List<String> list);

class AddTechButtonWidget extends StatelessWidget {
  final List<String> favTechIdsStringList;
  final FavTechListCallback callback;

  AddTechButtonWidget({this.favTechIdsStringList, this.callback});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.add_circle_outline),
        onPressed: () {
          _navigateToAddTech(context);
        }
    );
  }

  // A method that launches the SelectionScreen and awaits the
  // result from Navigator.pop.

  _navigateToAddTech(BuildContext context) async{
    final result = await Navigator.pushNamed(context, '/addTech', arguments: TechScreenArguments(favTechIdsStringList, true, null));

    if(result != null) {
      TechScreenArguments techScreenArguments = result;
      //favTechIdsStringList = techScreenArguments.favTechIdsStringList;
      if (techScreenArguments.snackBarText != null) {
        // After the AddTech Screen returns a result, hide any previous snackbars
        // and show the new result.

        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(techScreenArguments.snackBarText)));
      }
      callback(techScreenArguments.favTechIdsStringList);
    }
  }

}
