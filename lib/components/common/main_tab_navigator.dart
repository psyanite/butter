import 'dart:collection';

import 'package:butter/components/honor/scan_reward_screen.dart';
import 'package:butter/components/screens/home_screen.dart';
import 'package:butter/components/screens/settings_screen.dart';
import 'package:butter/presentation/crust_cons_icons.dart';
import 'package:butter/presentation/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainTabNavigator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MainTabNavigatorState();
}

class MainTabNavigatorState extends State<MainTabNavigator> {
  PageController _pageCtrl = PageController();
  Queue<int> _history;
  bool _lastActionWasGo;
  int _currentIndex = 0;
  Map<TabType, Tab> _tabs;

  @override
  initState() {
    super.initState();
    _history = Queue<int>();
    _history.addLast(0);
    _tabs = {
      TabType.home: Tab(widget: HomeScreen(), icon: CrustCons.bread_heart),
      TabType.scanReward: Tab(widget: ScanRewardScreen(), icon: CrustCons.qr),
//      TabType.newPost: Tab(widget: SelectStoreScreen(), icon: CrustCons.new_post),
      TabType.settings: Tab(widget: SettingsScreen(), icon: CrustCons.person)
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_tabs == null) return Container();
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: PageView(controller: _pageCtrl, onPageChanged: _onPageChanged, children: _tabs.values.map((t) => t.widget).toList()),
        bottomNavigationBar: Card(
          margin: EdgeInsets.all(0.0),
          elevation: 200.0,
          child: CupertinoTabBar(
            border: Border(top: BorderSide(color: Burnt.separator)),
            backgroundColor: Burnt.paper,
            activeColor: Burnt.primary,
            inactiveColor: Burnt.lightGrey,
            currentIndex: _currentIndex,
            onTap: _jumpToPage,
            items: _tabs.values.map((t) => BottomNavigationBarItem(icon: Icon(t.icon))).toList(),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() {
    if (_history.length == 0) {
      return Future(() => true);
    } else {
      var history = Queue<int>.from(_history);
      if (_lastActionWasGo) history.removeLast();
      var previousPage = history.removeLast();
      setState(() {
        _history = history;
        _lastActionWasGo = false;
      });
      _pageCtrl.jumpToPage(previousPage);
      return Future(() => false);
    }
  }

  _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  _jumpToPage(int index) {
    var history = Queue<int>.from(_history);
    history.addLast(index);
    setState(() {
      _history = history;
      _lastActionWasGo = true;
    });
    _pageCtrl.jumpToPage(index);
  }
}

enum TabType { home, scanReward, newPost, settings }

class Tab {
  final String name;
  final Widget widget;
  final IconData icon;

  const Tab({this.name, this.widget, this.icon});
}
