import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

import '../define/define.dart';
import '../define/lifeCycleEventHandler.dart';
import '../models/localLocationData.dart';
import '../utils/utils.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({Key? key}) : super(key: key);

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage>
    with TickerProviderStateMixin {
  var logger = Logger();

  late Timer _timer;
  bool isAppInactive = false; // バックグラウンド、FOREGROUND区別

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
        Duration(seconds: Define.CHECK_LOCATION_INTERVAL_SECOND), (timer) {});
    _timer.cancel();

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
              ElevatedButton(
                  onPressed: () {
                    locationServiceSubscription();
                  },
                  child: Text("locationServiceSubscription"))
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
    setState(() {

    });
  }

  Future<void> startLocationService() async {
    final _locationData =
        await GeolocatorPlatform.instance.getCurrentPosition();
    Utils.setLocationHistory(LocalLocationData(
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
}
