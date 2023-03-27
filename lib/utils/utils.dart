import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../define/define.dart';
import '../models/localLocationData.dart';

class Utils{
  static Future<void> setLocationHistory(LocalLocationData newData) async {
    var logger = Logger();
    logger.d("setLocationHistory");

    logger.d("222222222222222");

    // String? value = await storage.read(key: Define.KEYSTORE_LOCAL_LOCATION_DATA);
    // logger.d("33333333333");

    // List<dynamic> oldData = value != null ? jsonDecode(value) : [];
    //
    // DateTime _today = DateUtils.dateOnly(DateTime.now());
    // DateTime _sevenDateAgo = _today.add(const Duration(days: 7) * -1);
    logger.d("44444444444444");


    List<LocalLocationData> old = await getLocationHistory();

    // List<LocalLocationData> datas = [];
    // for (var i = 0; i < oldData.length; i++) {
    //   LocalLocationData decode = LocalLocationData.fromJson(oldData[i]);
    //   // 一週間前の位置情報は削除
    //   // if (decode.locationDateTime.isAfter(_sevenDateAgo)) {
    //     datas.add(decode);
    //   // }
    // }
    logger.d("1111111111111");

    old.add(newData);
    logger.d("22222222222222");
    logger.d(newData);

    var jsonNew = jsonEncode({"list": old});
    FlutterSecureStorage storage =FlutterSecureStorage();

    await storage.write(key: Define.KEYSTORE_LOCAL_LOCATION_DATA, value: jsonNew);
    // logger.d("[ローカルの位置情報登録]:${datas.toString()}");
  }

  /// ローカルの位置情報登録
  ///
  /// @param LocalLocationData 位置情報
  static Future<List<LocalLocationData>> getLocationHistory() async {
    var logger = Logger();

    const storage = FlutterSecureStorage();
    String? value =
    await storage.read(key: Define.KEYSTORE_LOCAL_LOCATION_DATA);
    logger.d(value);

    if(value==null){
      return [];
    }


    List<dynamic> decodes = value != null ? jsonDecode(value)["list"] : [];
    logger.d(decodes);

    List<LocalLocationData> datas = [];
    for (var i = 0; i < decodes.length; i++) {
      LocalLocationData target = LocalLocationData.fromJson(decodes[i]);
      datas.add(target);
    }
    return datas.reversed.toList();
  }

  static Future<void> clearHistory()async {
    const storage = FlutterSecureStorage();
storage.deleteAll();
  }

  static Future<void> setActive()async {
    const storage = FlutterSecureStorage();
    await storage.write(key: "active", value: "test");
  }
  static Future<void> removeActive()async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: "active");
  }

  static Future<bool> getActive()async {
    const storage = FlutterSecureStorage();
    String? result = await storage.read(key: "active",);
    return result==null?false:true;
  }


}