import 'package:dev_releases/src/App.dart';
import 'package:dev_releases/src/models/tech_model.dart';
import 'package:dev_releases/src/repository/tech_repository.dart';
import 'package:dev_releases/src/screens/home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<dynamic> firebaseMessagingBackgroundHandler(Map<String, dynamic> message) {
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
      Tech tech;
      if (message.containsKey('data')) {
        final dynamic data = message['data'];
        if(data['message_identifier'] == "new-tech-release") {
          if (favTechIdsStringList.contains(data['id'].toString())) {
            if(updateTechFromNotificationData(data)){
              // ignore: invalid_use_of_protected_member
              homeView.setState((){});
            }
          }
        }
      }
    },
    onBackgroundMessage: firebaseMessagingBackgroundHandler,
    onLaunch: (Map<String, dynamic> message) async {
      print("onLaunch: $message");
      if (message.containsKey('data')) {
        final dynamic data = message['data'];
        if(data['message_identifier'] == "new-tech-release") {
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
      print("onResume: $message");
      if (message.containsKey('data')) {
        final dynamic data = message['data'];
        if(data['message_identifier'] == "new-tech-release") {
          if (favTechIdsStringList.contains(data['id'].toString())) {
            updateTechFromNotificationData(data);
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
    print(
        "Could not parse firebase message to Tech Model :( [" + ex +
            "]");
    return false;
  }
  try {
    techRepository.updateTech(tech);
    print("Tech id [" + data['id'] + "] got an update");
    return true;
  } catch (ex) {
    print("Could not update Tech model:( [" + ex + "]");
    return false;
  }
}

