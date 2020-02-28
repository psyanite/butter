import 'dart:async';

import 'package:butter/main.dart';
import 'package:butter/presentation/theme.dart';
import 'package:butter/state/app/app_state.dart';
import 'package:butter/state/error/error_actions.dart';
import 'package:butter/state/me/me_actions.dart';
import 'package:butter/state/me/me_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen();

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, int>(
      onInit: (Store<AppState> store) {
        var me = store.state.me.user;
        if (me == null) {
          _redirect(context, MainRoutes.login);
          return;
        }

        _setupFcm(store);

        if (store.state.me.store != null) {
          _redirect(context, MainRoutes.home);
          return;
        }

        MeService.fetchStoreByAdminId(me.adminId).then((s) {
          if (s != null) {
            store.dispatch(FetchStoreSuccess(s));
            _redirect(context, MainRoutes.home);
          } else {
            _redirect(context, MainRoutes.contact);
          }
        }).catchError((e, stack) {
          store.dispatch(RequestFailure('fetchStoreByAdminId $e, $stack'));
        });
      },
      converter: (Store<AppState> store) => 1,
      builder: (BuildContext context, int props) {
        return _presenter();
      },
    );
  }

  _redirect(context, route) {
    return Timer(Duration(milliseconds: 500), () {
      Navigator.pushReplacementNamed(context, route);
    });
  }

  _setupFcm(Store<AppState> store) {
    store.dispatch(CheckFcmToken());
  }

  Widget _presenter() {
    return Scaffold(
      body: Container(
        child: Center(
          child: Image.asset('assets/images/loading-icon.png', height: 200.0),
        ),
        decoration: BoxDecoration(
          gradient: Burnt.burntGradient,
        ),
      ),
    );
  }
}
