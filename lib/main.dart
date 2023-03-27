import 'dart:async';

import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:test_alway_location/pages/p1_tap_main_page.dart';
import 'package:test_alway_location/utils/utils.dart';

import 'define/lifeCycleEventHandler.dart';
import 'models/localLocationData.dart';

@pragma('vm:entry-point')
void backgroundCallback() {
  BackgroundLocationTrackerManager.handleBackgroundUpdated(
    (data) async => Repo().update(data),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundLocationTrackerManager.initialize(
    backgroundCallback,
    config: const BackgroundLocationTrackerConfig(
      loggingEnabled: true,
      androidConfig: AndroidConfig(
        notificationIcon: 'explore',
        trackingInterval: Duration(seconds: 10),
        distanceFilterMeters: null,
      ),
      iOSConfig: IOSConfig(
        activityType: ActivityType.FITNESS,
        distanceFilterMeters: null,
        restartAfterKill: true,
      ),
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TapMainPage(),
    );
  }
}

class Repo extends State {
  var logger = Logger();
  static Repo? _instance;
  bool isAppInactive = false; // バックグラウンド、FOREGROUND区別

  Repo._();

  factory Repo() => _instance ??= Repo._();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(resumeCallBack: () async {
        isAppInactive = false;
        logger.d("isAppInactive:"+isAppInactive.toString());
      }, suspendingCallBack: () async {
        isAppInactive = true;
        logger.d("isAppInactive:"+isAppInactive.toString());
      }),
    );
  }

  Future<void> update(BackgroundLocationUpdateData data) async {
    await Utils.setLocationHistory(
        LocalLocationData(DateTime.now(), data.lat, data.lon, isAppInactive));
  }

  @override
  Widget build(BuildContext context) {
    return Text("");
  }
}
