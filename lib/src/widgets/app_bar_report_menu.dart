import 'package:dev_releases/src/helper/screen_arguments.dart';
import 'package:flutter/material.dart';

//typedef void FavTechListCallback(List<String> list);
enum ReportMenuOptions { MissingImage, AbusedImage, Custom }

class ReportMenu extends StatelessWidget {
  //final List<String> favTechIdsStringList;
  //final FavTechListCallback callback;

  //SettingButtonWidget({this.favTechIdsStringList, this.callback});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.bug_report),
        onPressed: () {
          _showReportOptionsDialog(context).then((result){
            print("Selected option: "+result.toString());
            if(result == ReportMenuOptions.Custom){
              _showCustomReportDialog(context).then((input){
                print("Custom issue text: "+input);
                //TODO Lets send custom mail with custom text
              });
            }else{
              //TODO Lets send predefined Mail
            }
          });
        }
    );
  }

  Future<ReportMenuOptions> _showReportOptionsDialog(BuildContext context) async{
    return await showDialog<ReportMenuOptions>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Whats your issue'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ReportMenuOptions.MissingImage);
                },
                child: const Text('Missing image'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ReportMenuOptions.AbusedImage);
                },
                child: const Text('Abused image'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ReportMenuOptions.Custom);
                },
                child: const Text('Other'),
              ),
            ],
          );
        });
  }

  Future<String> _showCustomReportDialog(BuildContext context) async{
    String input = '';
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter your issue'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                    maxLines: 4,
                    autofocus: true,
                    decoration: new InputDecoration(
                        labelText: 'Issue', hintText: 'Enter your issue'),
                    onChanged: (value) {
                      input = value;
                    },
                  ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(input);
              },
            ),
          ],
        );
      },
    );
}
}
