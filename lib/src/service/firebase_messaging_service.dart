import 'package:dev_releases/src/App.dart';
import 'package:dev_releases/src/models/tech_model.dart';
import 'package:dev_releases/src/repository/tech_repository.dart';
import 'package:dev_releases/src/screens/home_screen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<dynamic> backgroundHandle(Map<String, dynamic> message) {
  //This method name has to be 'backgroundHandle' otherwise we get java.lang.Integer cannot be cast to java.lang.Long on startup
  //See here: https://github.com/FirebaseExtended/flutterfire/issues/170
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}

void firebaseMessagingSubscribe(String topic) {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  _firebaseMessaging.subscribeToTopic(topic);
}

void firebaseMessagingUnSubscribe(String topic) {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  _firebaseMessaging.unsubscribeFromTopic(topic);
}

void firebaseMessagingConfigure(List<String> favTechIdsStringList, HomeView homeView){
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      print("firebase_messaging onMessage called");
      Tech tech;
      if (message.containsKey('data')) {
        final dynamic data = message['data'];
        if(data['message_identifier'] == 'new-release-'+data['id'].toString()) {
          if (favTechIdsStringList.contains(data['id'].toString())) {
            if(updateTechFromNotificationData(data)){
              // ignore: invalid_use_of_protected_member
              homeView.setState((){});
            }
          }
        }
      }
    },
    onBackgroundMessage: backgroundHandle,
    onLaunch: (Map<String, dynamic> message) async {
      print("firebase_messaging onLaunch called");
      if (message.containsKey('data')) {
        final dynamic data = message['data'];
        if(data['message_identifier'] == 'new-release-'+data['id'].toString()) {
          if (favTechIdsStringList.contains(data['id'].toString())) {
            if(updateTechFromNotificationData(data)){
              // ignore: invalid_use_of_protected_member
              homeView.setState((){});
            }
          }
        }
      }

    },
    onResume: (Map<String, dynamic> message) async {
      //This method is called when the app is in the background but its on standby
      print("firebase_messaging onResume called");
      if (message.containsKey('data')) {
        final dynamic data = message['data'];
        if(data['message_identifier'] == 'new-release-'+data['id'].toString()) {
          if (favTechIdsStringList.contains(data['id'].toString())) {
            if(updateTechFromNotificationData(data)){
              // ignore: invalid_use_of_protected_member
              homeView.setState((){});
            }
          }
        }
      }
    },
  );
  _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: true));

  _firebaseMessaging.onIosSettingsRegistered
      .listen((IosNotificationSettings settings) {
    print("Settings registered: $settings");
  });

  _firebaseMessaging.getToken().then((String token) {
    assert(token != null);
    print("Push Messaging token: $token");
  });
}

bool updateTechFromNotificationData(Map<dynamic, dynamic> data){
  TechRepository techRepository = new TechRepository();

  Tech tech;
  //Need new map because we get InternalLinkHashMap<dynamic, dynamic> from firebase
  var map = Map<String, dynamic>.from(data);
  try {
    tech = Tech.fromFirebaseMessage(map);
  } catch (ex) {
    Crashlytics.instance.recordError('Could not parse firebase message to Tech Model :(',ex);
    return false;
  }
  try {
    techRepository.updateTech(tech);
    print("Tech id [" + data['id'] + "] got an update");
    return true;
  } catch (ex) {
    Crashlytics.instance.recordError('Could not update Tech model from parsed firebase message:(',ex);
    return false;
  }
}

