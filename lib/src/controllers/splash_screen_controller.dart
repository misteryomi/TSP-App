import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/i18n.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart' as settingRepo;
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class SplashScreenController extends ControllerMVC {
  ValueNotifier<Map<String, double>> progress = new ValueNotifier(new Map());
  GlobalKey<ScaffoldState> scaffoldKey;

  SplashScreenController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    // Should define these variable before the app loaded
    progress.value = {"Setting": 0, "User": 0};
  }
  @override
  void initState() {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("splash screen onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("splash screen onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print(" splash screen  onResume: $message");
      },
      onBackgroundMessage: myBackgroundMessageHandler,
    );
    settingRepo.setting.addListener(() {
      if (settingRepo.setting.value.appName != null && settingRepo.setting.value.mainColor != null) {
        progress.value["Setting"] = 50;
        progress.notifyListeners();
      }
    });
    currentUser.addListener(() {
      if (currentUser.value.auth != null) {
        progress.value["User"] = 50;
        progress.notifyListeners();
      }
    });
    Timer(Duration(seconds: 20), () {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.current.verify_your_internet_connection),
      ));
    });

    super.initState();
  }

  static Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }
    print("splash screen myBackgroundMessageHandler");
  }
}
