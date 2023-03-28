import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../define/define.dart';
import '../models/localLocationData.dart';

class Utils {
  static late final SharedPreferences _prefs;

  static bool _init = false;
  static Future init() async {
    if (_init) return;
    _prefs = await SharedPreferences.getInstance();
    _init = true;
    return _prefs;
  }

  static Future<void> setLocationHistory(LocalLocationData newData) async {
    var logger = Logger();
    List<LocalLocationData> old = await getLocationHistory();
    newData.isAppActive = await Utils.getActive();
    old.add(newData);

    String jsonNew = jsonEncode({"list": old});
    await _prefs.setString(
         Define.KEYSTORE_LOCAL_LOCATION_DATA, jsonNew);
    logger.d("setLocationHistory:");
  }

  /// ローカルの位置情報登録
  ///
  /// @param LocalLocationData 位置情報
  static Future<List<LocalLocationData>> getLocationHistory() async {
    var logger = Logger();
    String? value =
    _prefs.getString( Define.KEYSTORE_LOCAL_LOCATION_DATA);

    if (value == null) {
      return [];
    }

    List<dynamic> list = jsonDecode(value)["list"];
    logger.d("getLocationHistory:"+list.length.toString());

    String lastTime = "";

    List<LocalLocationData> datas = [];
    for (var i = 0; i < list.length; i++) {
      LocalLocationData target = LocalLocationData.fromJson(list[i]);

      String targetTime =
          DateFormat('yyyy-MM-dd hh:mm').format(target.locationDateTime);
      if (lastTime.isEmpty || targetTime != lastTime) {
        datas.add(target);
        lastTime =
            DateFormat('yyyy-MM-dd hh:mm').format(target.locationDateTime);
      }
    }
    // logger.i(datas.toString());
    return datas;
  }

  static Future<List<LocalLocationData>> getLocationHistoryReverse() async {
    var logger = Logger();
    String? value =
    _prefs.getString( Define.KEYSTORE_LOCAL_LOCATION_DATA);

    if (value == null) {
      return [];
    }

    List<dynamic> list = jsonDecode(value)["list"];
    logger.d("getLocationHistory:"+list.length.toString());

    String lastTime = "";

    List<LocalLocationData> datas = [];
    for (var i = 0; i < list.length; i++) {
      LocalLocationData target = LocalLocationData.fromJson(list[i]);

      String targetTime =
      DateFormat('yyyy-MM-dd hh:mm').format(target.locationDateTime);
      if (lastTime.isEmpty || targetTime != lastTime) {
        datas.add(target);
        lastTime =
            DateFormat('yyyy-MM-dd hh:mm').format(target.locationDateTime);
      }
    }
    // logger.i(datas.toString());
    return datas.reversed.toList();
  }

  static Future<void> clearHistory() async {
    _prefs.clear();
  }

  static Future<void> setActive() async {
    var logger = Logger();
    logger.d("Active");
    await _prefs.setBool( "active", true);
  }

  static Future<void> inActive() async {
    var logger = Logger();
    logger.d("InActive");
    await _prefs.setBool( "active", false);
  }

  static Future<bool> getActive() async {
    bool? result = _prefs.getBool( "active");
    return result??true;
  }
}
