import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(
         Define.KEYSTORE_LOCAL_LOCATION_DATA, jsonNew);
  }

  /// ローカルの位置情報登録
  ///
  /// @param LocalLocationData 位置情報
  static Future<List<LocalLocationData>> getLocationHistory() async {
    var logger = Logger();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value =
        await prefs.getString( Define.KEYSTORE_LOCAL_LOCATION_DATA);
    // logger.d(value);

    if (value == null) {
      return [];
    }

    List<dynamic> decodes = value != null ? jsonDecode(value)["list"] : [];
    // logger.d(decodes);

    String lastTime = "";

    List<LocalLocationData> datas = [];
    for (var i = 0; i < decodes.length; i++) {
      LocalLocationData target = LocalLocationData.fromJson(decodes[i]);

      String targetTime =
          DateFormat('yyyy-MM-dd hh:mm').format(target.locationDateTime);
      if (lastTime.isEmpty || targetTime != lastTime) {
        datas.add(target);
        lastTime =
            DateFormat('yyyy-MM-dd hh:mm').format(target.locationDateTime);
      }
    }
    return datas.reversed.toList();
  }

  static Future<void> clearHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  static Future<void> setActive() async {
    var logger = Logger();
    logger.d("Active");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool( "active", true);
  }

  static Future<void> inActive() async {
    var logger = Logger();
    logger.d("InActive");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool( "active", false);
  }

  static Future<bool> getActive() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? result = prefs.getBool( "active");
    return result??true;
  }
}
