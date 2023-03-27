import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:test_alway_location/pages/tab/p3_list_page.dart';

import '../utils/utils.dart';
import 'tab/p2_permission_page.dart';

class TapMainPage extends StatefulWidget {
  const TapMainPage({Key? key}) : super(key: key);

  @override
  State<TapMainPage> createState() => _TapMainPageState();
}

class _TapMainPageState extends State<TapMainPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabController;
  var logger = Logger();

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
    await Utils.setActive();

  }

  Future<void> detachedCallBack() async {
    await Utils.inActive();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "test",
      home: DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Scaffold(
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
