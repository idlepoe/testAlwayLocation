import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_alway_location/pages/p3_list_page.dart';

import 'p2_permission_page.dart';

class TapMainPage extends StatefulWidget {
  const TapMainPage({Key? key}) : super(key: key);

  @override
  State<TapMainPage> createState() => _TapMainPageState();
}

class _TapMainPageState extends State<TapMainPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        await detachedCallBack();
        break;
      case AppLifecycleState.resumed:
        await resumeCallBack();
        break;
    }
  }

  Future<void> resumeCallBack() async {
    print("resumeCallBack");
  }

  Future<void> detachedCallBack() async {
    print("detachedCallBack");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "test",
      home: DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
                title: Text(
                  "test",
                  style: TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.white),
            body: TabBarView(
              controller: _tabController,
              children: [
                PermissionPage(),
                ListPage(),
              ],
            ),
            bottomNavigationBar: TabBar(
              controller: _tabController,
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.black,
              indicatorColor: Colors.lightBlue,
              tabs: [
                Tab(text: "permission"),
                Tab(text: "list"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}