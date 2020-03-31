import 'package:dev_releases/src/helper/screen_arguments.dart';
import 'package:dev_releases/src/models/tech_model.dart';
import 'package:dev_releases/src/service/report_service.dart';
import 'package:flutter/material.dart';

enum ReportMenuOptions { MissingImage, AbusedImage, Custom }

class ReportMenu extends StatelessWidget {
  final Tech tech;

  ReportMenu({this.tech});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.bug_report),
        onPressed: () {
          _showReportOptionsDialog(context).then((result) {
            print("Selected option: " + result.toString());
            if (result == ReportMenuOptions.Custom) {
              _showCustomReportDialog(context).then((input) {
                //we have to result.toString().split('.').last because otherwise we get ReportMenuOptions.Custom
                sendBugReport(tech, result.toString().split('.').last, input);
              });
            } else {
              //we have to result.toString().split('.').last because otherwise we get ReportMenuOptions.MissingImage
              sendBugReport(tech, result.toString().split('.').last, '');
            }
            displaySnackBar(context, "Thanks for your support");
          });
        });
  }

  Future<ReportMenuOptions> _showReportOptionsDialog(
      BuildContext context) async {
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

  Future<String> _showCustomReportDialog(BuildContext context) async {
    String input = '';
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
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

  void displaySnackBar(BuildContext context, String snackBarText) {
    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(snackBarText)));
  }
}
