import 'dart:async';

import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../define/define.dart';
import '../../define/lifeCycleEventHandler.dart';
import '../../main.dart';
import '../../models/localLocationData.dart';
import '../../utils/utils.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({Key? key}) : super(key: key);

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  var logger = Logger();
  String text = "Stop Service";

  late Timer _timer;
  bool isAppInactive = false; // バックグラウンド、FOREGROUND区別

  var isTracking = false;

  List<String> _locations = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getTrackingStatus();
    _startLocationsUpdatesStream();

    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(resumeCallBack: () async {
        isAppInactive = false;
      }, suspendingCallBack: () async {
        isAppInactive = true;
      }),
    );
  }

  String permissionStatus = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(permissionStatus),
              ElevatedButton(
                  onPressed: () {
                    getLocationPermission();
                  },
                  child: Text("getLocationPermission")),
              Text("_timer.isActive:" + _timer.isActive.toString()),
              MaterialButton(
                child: const Text('Start Tracking'),
                onPressed: isTracking
                    ? null
                    : () async {
                        await BackgroundLocationTrackerManager.startTracking();
                        setState(() => isTracking = true);
                      },
              ),
              MaterialButton(
                child: const Text('Stop Tracking'),
                onPressed: isTracking
                    ? () async {
                        await _getLocations();
                        await BackgroundLocationTrackerManager.stopTracking();
                        setState(() => isTracking = false);
                      }
                    : null,
              ),
              // ElevatedButton(
              //   child: Text(text),
              //   onPressed: () async {
              //     final service = FlutterBackgroundService();
              //     var isRunning = await service.isRunning();
              //     if (isRunning) {
              //       service.invoke("stopService");
              //     } else {
              //       service.startService();
              //     }
              //
              //     if (!isRunning) {
              //       text = 'Stop Service';
              //     } else {
              //       text = 'Start Service';
              //     }
              //     setState(() {});
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getLocationPermission() async {
    await Geolocator.requestPermission();
    LocationPermission permission = await Geolocator.checkPermission();

    switch (permission) {
      case LocationPermission.denied:
        setState(() {
          permissionStatus = "LocationPermission.denied";
        });
        break;
      case LocationPermission.deniedForever:
        setState(() {
          permissionStatus = "LocationPermission.deniedForever";
        });
        break;
      case LocationPermission.unableToDetermine:
        setState(() {
          permissionStatus = "LocationPermission.unableToDetermine";
        });
        break;
      case LocationPermission.always:
        setState(() {
          permissionStatus = "LocationPermission.always";
        });
        break;
      case LocationPermission.whileInUse:
        setState(() {
          permissionStatus = "LocationPermission.whileInUse";
        });
        break;
    }
  }

  Future<void> locationServiceSubscription() async {
    logger.d("locationServiceSubscription");

    _timer = Timer.periodic(
        const Duration(seconds: Define.CHECK_LOCATION_INTERVAL_SECOND),
        (Timer t) async {
      logger.d("interval locationServiceSubscription");
      await startLocationService();
    });
    setState(() {});
  }

  Future<void> startLocationService() async {
    final _locationData =
        await GeolocatorPlatform.instance.getCurrentPosition();
    await Utils.setLocationHistory(LocalLocationData(
        DateTime.now(),
        _locationData.latitude ?? 0,
        _locationData.longitude ?? 0,
        isAppInactive));
    logger.d("位置情報保存：" +
        LocalLocationData(DateTime.now(), _locationData.latitude ?? 0,
                _locationData.longitude ?? 0, isAppInactive)
            .toString());
  }

  cancelTimer() {
    _timer.cancel();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _getTrackingStatus() async {
    isTracking = await BackgroundLocationTrackerManager.isTracking();
    setState(() {});
  }

  Future<void> _requestLocationPermission() async {
    final result = await Permission.locationAlways.request();
    if (result == PermissionStatus.granted) {
      print('GRANTED'); // ignore: avoid_print
    } else {
      print('NOT GRANTED'); // ignore: avoid_print
    }
  }

  Future<void> _requestNotificationPermission() async {
    final result = await Permission.notification.request();
    if (result == PermissionStatus.granted) {
      print('GRANTED'); // ignore: avoid_print
    } else {
      print('NOT GRANTED'); // ignore: avoid_print
    }
  }

  Future<void> _getLocations() async {
    final locations = await LocationDao().getLocations();
    setState(() {
      _locations = locations;
    });
  }

  void _startLocationsUpdatesStream() {
    _timer = Timer.periodic(
        const Duration(milliseconds: 250), (timer) => _getLocations());
  }
}
