import 'package:dev_releases/src/models/tech_model.dart';
import 'package:dev_releases/src/repository/tech_repository.dart';
import 'package:dev_releases/src/service/shared_preferences_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

typedef void SettingsSavedCallback(bool finish);

class SaveSettingsButtonWidget extends StatelessWidget {
  final List<String> favTechIdsStringList;
  final List<Tech> remoteTechData;
  final SettingsSavedCallback callback;
  final TechRepository techRepository = new TechRepository();

  SaveSettingsButtonWidget(
      {this.favTechIdsStringList, this.remoteTechData, this.callback});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () {
          _saveSettings(context);
        },
        tooltip: "Save");
  }

  void _saveSettings(BuildContext context) {
    if (remoteTechData.length > 0) {
      List<Tech> relevantTechList = new List();
      for (int i = 0; i < favTechIdsStringList.length; i++) {
        int id = int.parse(favTechIdsStringList[i]);
        Tech remoteTech = remoteTechData.singleWhere((item) => item.id == id,
            orElse: () => null);
        if (remoteTech != null) {
          relevantTechList.add(remoteTech);
        }
      }
      if (relevantTechList.length > 0) {
        Future.wait([
          techRepository.insertOrUpdateTechList(relevantTechList),
          setLocalTechs(favTechIdsStringList)
        ]).then((List responses) {
          print("finish: " + responses.toString());
          callback(true);
        }).catchError((e) =>
            FirebaseCrashlytics.instance.recordError('Could not save settings', e));
      } else {
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Select atleast one item')));
      }
    } else {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Please wait for the data')));
    }
  }
}
