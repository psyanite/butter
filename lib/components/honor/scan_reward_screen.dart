import 'package:barcode_scan/barcode_scan.dart';
import 'package:butter/components/honor/honor_reward_screen.dart';
import 'package:butter/main.dart';
import 'package:butter/models/reward.dart';
import 'package:butter/models/user_reward.dart';
import 'package:butter/presentation/components.dart';
import 'package:butter/presentation/theme.dart';
import 'package:butter/services/toaster.dart';
import 'package:butter/state/app/app_state.dart';
import 'package:butter/state/reward/reward_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';

class ScanRewardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, dynamic>(
      converter: (Store<AppState> store) => _Props.fromStore(store),
      builder: (context, props) => _Presenter(myAdminId: props.myAdminId),
    );
  }
}

class _Presenter extends StatefulWidget {
  final int myAdminId;

  _Presenter({Key key, this.myAdminId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PresenterState();
}

class _PresenterState extends State<_Presenter> {
  String _error;

  _load() async {
    var code = await _scan();
    if (code == null) return;

    var result = await RewardService.canHonorUserReward(widget.myAdminId, code);
    var error = result['error'];
    if (error != null) {
      var userReward = await RewardService.fetchUserRewardByCode(code);
      if (userReward == null) {
        _setErrorCode('4014');
      } else if (error == 'Invalid adminId') {
        _redirect(_InvalidRewardScreen(reward: userReward.reward));
      } else if (error == 'Already redeemed') {
        _redirect(_AlreadyRedeemedScreen(reward: userReward.reward));
      } else {
        Toaster.logError('Validate Reward', 'Could not validate userReward: $userReward');
        _setError('Oops! Something went wrong, please contact support.');
      }
      return;
    }
      var userReward = result['userReward'] as UserReward;
    if (userReward == null) {
      Toaster.logError('Validate Reward', 'Could not parse userReward: $userReward');
      _setError('Oops! Something went wrong, please contact support.');
      return;
    }

    if (userReward.reward.isExpired()) {
      var lastDay = DateFormat.MMMEd('en_US').format(userReward.reward.validUntil);
      _setError('Sorry, this reward expired on the $lastDay');
      return;
    }

    _redirect(HonorRewardScreen(userReward: userReward));
  }

  _scan() async {
    try {
      var result = await BarcodeScanner.scan();
      if (result != null) {
        return result;
      } else {
        _setErrorCode('4013');
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        _setErrorCode('4012');
      } else {
        _setErrorCode('4011');
      }
    } on FormatException {
      // Back button pressed, do nothing.
    } catch (e) {
      print(e);
      _setErrorCode('4010');
    }
    return null;
  }

  _redirect(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  _setError(String msg) {
    this.setState(() => _error = msg);
  }

  _setErrorCode(String code) {
    this.setState(() => _error = 'Sorry, we couldn\'t recognise this QR code, error $code occurred, please try again.');
  }

  _retry() {
    this.setState(() => _error = null);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _content(),
      ),
    );
  }

  Widget _content() {
    if (_error != null) return _errorMessage();
    return _openCameraButton();
  }

  Widget _openCameraButton() {
    return SmallSolidButton(
      onTap: _load,
      padding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 15.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.camera_alt, color: Colors.white, size: 50.0),
            Container(height: 5.0),
            Text('Scan Reward', style: TextStyle(fontSize: 22.0, color: Colors.white)),
          ],
        )],
      ),
    );
  }

  Widget _errorMessage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(_error, textAlign: TextAlign.center, style: TextStyle(fontSize: 30.0)),
        Container(height: 20.0),
        _GoAgainButton(onTap: _retry),
      ],
    );
  }
}

class _Props {
  final int myAdminId;

  _Props({this.myAdminId});

  static fromStore(Store<AppState> store) {
    return _Props(
      myAdminId: store.state.me.user.adminId,
    );
  }
}

class _InvalidRewardScreen extends StatelessWidget {
  final Reward reward;

  _InvalidRewardScreen({Key key, this.reward}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var boldStyle = TextStyle(fontSize: 30.0, fontWeight: Burnt.fontBold);
    var lightStyle = TextStyle(fontSize: 30.0);
    var goAgain = () => Navigator.popUntil(context, ModalRoute.withName(MainRoutes.home));
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Invalid Reward', textAlign: TextAlign.center, style: lightStyle),
              Container(height: 30.0),
              Text(reward.name, textAlign: TextAlign.center, style: boldStyle),
              Text('cannot be redeemed here, sorry.', textAlign: TextAlign.center, style: lightStyle),
              Container(height: 20),
              Text('It can be redeemed at', textAlign: TextAlign.center, style: lightStyle),
              Text(reward.storeNameText(), textAlign: TextAlign.center, style: boldStyle),
              Text(reward.locationText(), textAlign: TextAlign.center, style: boldStyle),
              Container(height: 30.0),
              _GoAgainButton(onTap: goAgain),
            ],
          ),
        ),
      )
    );
  }
}

class _AlreadyRedeemedScreen extends StatelessWidget {
  final Reward reward;

  _AlreadyRedeemedScreen({Key key, this.reward}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var boldStyle = TextStyle(fontSize: 30.0, fontWeight: Burnt.fontBold);
    var lightStyle = TextStyle(fontSize: 30.0);
    var goAgain = () => Navigator.popUntil(context, ModalRoute.withName(MainRoutes.home));
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Invalid Reward', textAlign: TextAlign.center, style: lightStyle),
              Container(height: 30.0),
              Text(reward.name, textAlign: TextAlign.center, style: boldStyle),
              Text('can only be redeemed once, and it has already been redeemed, sorry.', textAlign: TextAlign.center, style: lightStyle),
              Container(height: 30.0),
              _GoAgainButton(onTap: goAgain),
            ],
          ),
        ),
      )
    );
  }
}

class _GoAgainButton extends StatelessWidget {
  final Function onTap;

  _GoAgainButton({Key key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SmallSolidButton(
      onTap: onTap,
      padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 10.0, bottom: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[Text('Go Back to Scanner', style: TextStyle(fontSize: 22.0, color: Colors.white))],
      ),
    );
  }
}
