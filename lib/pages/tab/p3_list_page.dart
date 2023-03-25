import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../../define/define.dart';
import '../../models/localLocationData.dart';
import '../../utils/utils.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  var logger = Logger();


  List<LocalLocationData> _list = [];
  String _locationPermissionString = "";



  final Widget _optionDivider = Divider(
    indent: 10,
    endIndent: 10,
    height: 5,
    color: Colors.grey,
  );



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("位置情報取得状況確認",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(onPressed: () async {
            await  getList();
          }, child: Text("get list")),
          TextButton(onPressed: () async {
            await Utils.clearHistory();
            await  getList();
          }, child: Text("clear history"))
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("位置情報権限"),
                  Text(_locationPermissionString),
                ],
              ),
            ),
            _optionDivider,
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("位置情報取得INTERVAL"),
                  Text(Define.CHECK_LOCATION_INTERVAL_SECOND.toString() + "秒"),
                ],
              ),
            ),
            _optionDivider,
            Container(
              height: MediaQuery.of(context).size.height - 150,
              child: ListView.separated(
                itemCount: _list.length,
                scrollDirection: Axis.vertical,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) => Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: ListTile(
                    title: Text(DateFormat('yyyy-MM-dd hh:mm').format(_list[index].locationDateTime)),
                    subtitle: Text(
                        _list[index].locationLongitude.toString() +
                            "," +
                            _list[index].locationLatitude.toString() +
                            "(" +
                            ((_list[index].isAppInactive ?? false)
                                ? "BACKGROUND"
                                : "FOREGROUND") +
                            ")"),
                  ),
                ),
                separatorBuilder: (context, index) => SizedBox(width: 8),
              ),
            ),
            _optionDivider,
          ]),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    init();

  }

  Future<void>init() async {

getList();
  }

  Future<void> getList()async {
    var result = await Geolocator.checkPermission();
    _locationPermissionString = result.name;
    var result1 = await Utils.getLocationHistory();
    // 位置情報取得
    setState(() {
      _list = result1;
    });
    logger.d("getDateLocationHistory()", _list.toString());
  }
}
