import 'package:dev_releases/src/models/tech_model.dart';
import 'package:dev_releases/src/repository/tech_repository.dart';
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

void firebaseMessagingConfigure(List<String> favTechIdsStringList, BuildContext context){
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  TechRepository techRepository = new TechRepository();

  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      Tech tech;
      if(message['notification']['title'] == "New github release") {
        if (message.containsKey('data')) {
          // Handle data message
          final dynamic data = message['data'];
          if (favTechIdsStringList.contains(data['id'].toString())) {
            Tech tech;
            //Need new map because we get InternalLinkHashMap<dynamic, dynamic> from firebase
            var map = Map<String, dynamic>.from(data);
            try {
              tech = Tech.fromFirebaseMessage(map);
            } catch (ex) {
              print(
                  "Could not parse firebase message to Tech Model :( [" + ex +
                      "]");
            }
            try {
              techRepository.updateTech(tech);
              print("Tech id" + data['id'] + "got an update");
            } catch (ex) {
              print("Could not update Tech model:( [" + ex + "]");
            }
          }
        }
      }
    },
    onBackgroundMessage: firebaseMessagingBackgroundHandler,
    onLaunch: (Map<String, dynamic> message) async {
      print("onLaunch: $message");
      showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title: Text("Alert Dialog"),
              content: Text(message.toString()),
            );
          }
      );

    },
    onResume: (Map<String, dynamic> message) async {
      //TODO Prevent notification if the user does not have the tech as favorite
      //TODO update tech when the notification were called from background (here)
      print("onResume: $message");
      showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title: Text("Alert Dialog"),
              content: Text(message.toString()),
            );
          }
      );
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