import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:vaccio/controller/AppController.dart';
import 'package:vaccio/res/colors.dart' as colors;
import 'Home.dart';
import 'Precautions.dart';
import 'Settings.dart';
import 'Appointments.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  TabController _tabController;
  var nav = Get.put(AppController());
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _listTabs.length);
    _tabController.animateTo(nav.index.value);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<Widget> _listTabs = [
    HomeScreen(),
    Appointments(),
    Precautions(),
    Settings()
  ];

  Widget _bottomNavigationBar() {
    return Obx(() => BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: nav.index.value,
            onTap: (index) {
              nav.navigate(index);
              _tabController.animateTo(index);
            },
            selectedItemColor: colors.c4,
            unselectedItemColor: Colors.grey,
            unselectedLabelStyle:
                TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            type: BottomNavigationBarType.fixed,
            iconSize: 25.0,
            items: [
              BottomNavigationBarItem(
                  activeIcon: Icon(
                    FeatherIcons.home,
                    color: colors.c4,
                  ),
                  icon: Icon(
                    FeatherIcons.home,
                    color: Colors.grey,
                  ),
                  label: "Home"),
              BottomNavigationBarItem(
                  activeIcon: Icon(
                    FeatherIcons.calendar,
                    color: colors.c4,
                  ),
                  icon: Icon(
                    FeatherIcons.calendar,
                    color: Colors.grey,
                  ),
                  label: "Appointments"),
              BottomNavigationBarItem(
                  activeIcon: Icon(
                    FeatherIcons.alertTriangle,
                    color: colors.c4,
                  ),
                  icon: Icon(
                    FeatherIcons.alertTriangle,
                    color: Colors.grey,
                  ),
                  label: "Precautions"),
              BottomNavigationBarItem(
                  activeIcon: Icon(
                    FeatherIcons.settings,
                    color: colors.c4,
                  ),
                  icon: Icon(
                    FeatherIcons.settings,
                    color: Colors.grey,
                  ),
                  label: "Settings"),
            ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: TabBarView(
          children: _listTabs,
          controller: _tabController,
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: _bottomNavigationBar());
  }
}
