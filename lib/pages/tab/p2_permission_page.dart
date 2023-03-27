import 'dart:async';

import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

import '../../define/lifeCycleEventHandler.dart';
import '../../main.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({Key? key}) : super(key: key);

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  var logger = Logger();
  String text = "Stop Service";

  bool isAppInactive = false; // バックグラウンド、FOREGROUND区別

  var isTracking = false;

  @override
  void initState() {
    super.initState();
    _getTrackingStatus();

    // WidgetsBinding.instance.addObserver(
    //   LifecycleEventHandler(resumeCallBack: () async {
    //     isAppInactive = false;
    //   }, suspendingCallBack: () async {
    //     isAppInactive = true;
    //   }),
    // );
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
              Text("isTracking:" + isTracking.toString()),
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
                        await BackgroundLocationTrackerManager.stopTracking();
                        setState(() => isTracking = false);
                      }
                    : null,
              ),
              Repo().build(context),
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

  @override
  bool get wantKeepAlive => true;

  Future<void> _getTrackingStatus() async {
    isTracking = await BackgroundLocationTrackerManager.isTracking();
    setState(() {});
  }

}
