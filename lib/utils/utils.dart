import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../define/define.dart';
import '../models/localLocationData.dart';

class Utils {
  static Future<void> setLocationHistory(LocalLocationData newData) async {
    var logger = Logger();
    logger.d("setLocationHistory" + newData.toString());
    List<LocalLocationData> old = await getLocationHistory();
    newData.isAppActive = await Utils.getActive();
    old.add(newData);
    var jsonNew = jsonEncode({"list": old});
    FlutterSecureStorage storage = FlutterSecureStorage();

    await storage.write(
        key: Define.KEYSTORE_LOCAL_LOCATION_DATA, value: jsonNew);
  }

  /// ローカルの位置情報登録
  ///
  /// @param LocalLocationData 位置情報
  static Future<List<LocalLocationData>> getLocationHistory() async {
    var logger = Logger();

    const storage = FlutterSecureStorage();
    String? value =
        await storage.read(key: Define.KEYSTORE_LOCAL_LOCATION_DATA);
    // logger.d(value);

    if (value == null) {
      return [];
    }

    List<dynamic> decodes = value != null ? jsonDecode(value)["list"] : [];
    logger.d(decodes);

    DateTime? lastTime;

    List<LocalLocationData> datas = [];
    for (var i = 0; i < decodes.length; i++) {
      LocalLocationData target = LocalLocationData.fromJson(decodes[i]);

      DateTime targetTime = target.locationDateTime;
      if (lastTime == null || targetTime.difference(lastTime).inMinutes.abs() > Define.HISTORY_INTERVAL) {
        datas.add(target);
        lastTime = target.locationDateTime;
      }
    }
    return datas.reversed.toList();
  }

  static Future<void> clearHistory() async {
    const storage = FlutterSecureStorage();
    storage.deleteAll();
  }

  static Future<void> setActive() async {
    var logger = Logger();
    logger.d("Active");
    const storage = FlutterSecureStorage();
    await storage.write(key: "active", value: "test");
  }

  static Future<void> inActive() async {
    var logger = Logger();
    logger.d("InActive");
    const storage = FlutterSecureStorage();
    await storage.delete(key: "active");
  }

  static Future<bool> getActive() async {
    const storage = FlutterSecureStorage();
    String? result = await storage.read(
      key: "active",
    );
    return result == null ? false : true;
  }
}
