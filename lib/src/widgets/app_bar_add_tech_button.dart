import 'package:dev_releases/src/helper/screen_arguments.dart';
import 'package:flutter/material.dart';

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
