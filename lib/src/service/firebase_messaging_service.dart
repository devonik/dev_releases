import 'package:dev_releases/src/helper/constants.dart';
import 'package:dev_releases/src/models/tech_model.dart';
import 'package:dev_releases/src/repository/tech_repository.dart';
import 'package:dev_releases/src/screens/home_screen.dart';
import 'package:dev_releases/src/service/tech_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
}

void firebaseMessagingSubscribe(String topic) {
  FirebaseMessaging.instance.subscribeToTopic(topic);
}

void firebaseMessagingUnSubscribe(String topic) {
  FirebaseMessaging.instance.unsubscribeFromTopic(topic);
}

void initFirebaseTopicSubscription(List<String> favTechIdsStringList) {
  favTechIdsStringList.forEach((element) {
    firebaseMessagingSubscribe('new-release-' + element);
  });
}

void firebaseMessagingConfigure(List<String> favTechIdsStringList) {
  TechRepository techRepository = new TechRepository();

  initFirebaseTopicSubscription(favTechIdsStringList);

  //Handle foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.data != null) {
      if (message.data['message_identifier'] ==
          'new-release-' + message.data['id'].toString()) {
        if (favTechIdsStringList.contains(message.data['id'].toString())) {
          updateTechFromNotificationData(message.data);
        }
      }
    }
  });

  //Set background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  //Request permission (Need fo IOS)
  FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  //Add web token for firebase handshake (Need for web)
  FirebaseMessaging.instance
      .getToken(vapidKey: Constants.firebaseWebPushCertificateKey);
}

bool updateTechFromNotificationData(Map<String, dynamic> data) {
  TechRepository techRepository = new TechRepository();

  Tech tech;
  //Need new map because we get InternalLinkHashMap<dynamic, dynamic> from firebase
  //var map = Map<String, dynamic>.from(data);
  try {
    tech = Tech.fromFirebaseMessage(data);
  } catch (ex) {
    FirebaseCrashlytics.instance
        .recordError('Could not parse firebase message to Tech Model :(', ex);
    return false;
  }
  try {
    techRepository.updateTech(tech);
    debugPrint("Tech id [" + data['id'] + "] got an update");
    return true;
  } catch (ex) {
    FirebaseCrashlytics.instance.recordError(
        'Could not update Tech model from parsed firebase message:(', ex);
    return false;
  }
}
