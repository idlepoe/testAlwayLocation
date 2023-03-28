import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_alway_location/pages/p1_tap_main_page.dart';
import 'package:test_alway_location/utils/utils.dart';

import 'define/define.dart';
import 'models/localLocationData.dart';

@pragma('vm:entry-point')
Future<void> backgroundCallback() async {
  BackgroundLocationTrackerManager.handleBackgroundUpdated(
    (data) async => Repo().update(data),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundLocationTrackerManager.initialize(
    backgroundCallback,
    config: BackgroundLocationTrackerConfig(
      loggingEnabled: true,
      androidConfig: AndroidConfig(
        notificationIcon: 'explore',
        trackingInterval: Duration(seconds: Define.CHECK_LOCATION_INTERVAL_SECOND),
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

class Repo {
  static Repo? _instance;

  Repo._();

  factory Repo() => _instance ??= Repo._();

  Future<void> update(BackgroundLocationUpdateData data) async {
    final text = 'Location Update: Lat: ${data.lat} Lon: ${data.lon}';
    print(text); // ignore: avoid_print
    // sendNotification(text);
    await LocationDao().saveLocation(LocalLocationData(DateTime.now(), data.lat, data.lon, true));
  }
}

class LocationDao {
  static const _locationsKey = 'LocalLocationData';
  static const _locationSeparator = '-/-/-/';

  static LocationDao? _instance;

  LocationDao._();

  factory LocationDao() => _instance ??= LocationDao._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<void> saveLocation(LocalLocationData data) async {
    List<LocalLocationData> locations = await getLocations();
    locations.add(data);
    await (await prefs)
        .setString(_locationsKey, jsonEncode({"list": locations}));
  }

  Future<List<LocalLocationData>> getLocations() async {
    final prefs = await this.prefs;
    await prefs.reload();
    final locationsString = prefs.getString(_locationsKey);
    if (locationsString == null) return [];
    List<dynamic> list = jsonDecode(locationsString)["list"];
    List<LocalLocationData> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(LocalLocationData.fromJson(list[i]));
    }
    return result;
  }

  Future<void> clear() async => (await prefs).clear();
}

void sendNotification(String text) {
  const settings = InitializationSettings(
    android: AndroidInitializationSettings('app_icon'),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    ),
  );
  FlutterLocalNotificationsPlugin().initialize(
    settings,
    onDidReceiveNotificationResponse: (data) async {
      print('ON CLICK $data'); // ignore: avoid_print
    },
  );
  FlutterLocalNotificationsPlugin().show(
    Random().nextInt(9999),
    'Title',
    text,
    const NotificationDetails(
      android: AndroidNotificationDetails('test_notification', 'Test'),
      iOS: DarwinNotificationDetails(),
    ),
  );
}
