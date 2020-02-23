import 'package:butter/components/dialog/confirm.dart';
import 'package:butter/main.dart';
import 'package:butter/models/user.dart';
import 'package:butter/presentation/components.dart';
import 'package:butter/presentation/theme.dart';
import 'package:butter/state/app/app_state.dart';
import 'package:butter/state/me/me_actions.dart';
import 'package:butter/utils/general_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _Props>(
      converter: (Store<AppState> store) => _Props.fromStore(store),
      builder: (BuildContext context, _Props props) {
        return _presenter(context, props.me?.username, props.logout);
      },
    );
  }

  Widget _presenter(context, String username, Function logout) {
    var email = () => launch(Utils.buildEmail('Register Success', 'Request for complete setup process.\n\nUsername: $username'));
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Thanks for registering.', textAlign: TextAlign.center),
              Container(height: 5.0),
              Text('Please contact us to complete the setup process.', textAlign: TextAlign.center),
              Container(height: 20.0),
              Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                HollowButton(
                  children: <Widget>[Text('Logout')],
                  onTap: () => showDialog(context: context, builder: (context) => _logoutDialog(context, logout)),
                  padding: EdgeInsets.symmetric(horizontal: 22.0, vertical: 9.0),
                  borderColor: Burnt.lightGrey,
                ),
                Container(width: 10.0),
                SmallSolidButton(
                  child: Text('Email Us', style: TextStyle(color: Colors.white)),
                  onTap: email,
                  padding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 9.0),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoutDialog(context, logout) {
    return Confirm(
      title: 'Logout',
      description: 'Would you like to logout?',
      action: 'Logout',
      onTap: () {
        logout();
        Navigator.pushReplacementNamed(context, MainRoutes.login);
      },
    );
  }
}

class _Props {
  final User me;
  final Function logout;

  _Props({this.me, this.logout});

  static fromStore(Store<AppState> store) {
    return _Props(
      me: store.state.me.user,
      logout: () => store.dispatch(Logout()),
    );
  }
}
