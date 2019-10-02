import 'package:butter/components/common/store_banner.dart';
import 'package:butter/components/dialog/confirm.dart';
import 'package:butter/components/my_store/my_qr_screen.dart';
import 'package:butter/components/my_store/update_store_screen.dart';
import 'package:butter/components/screens/about_screen.dart';
import 'package:butter/main.dart';
import 'package:butter/models/store.dart' as MyStore;
import 'package:butter/presentation/theme.dart';
import 'package:butter/state/app/app_state.dart';
import 'package:butter/state/me/me_actions.dart';
import 'package:butter/utils/general_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, dynamic>(
      converter: (Store<AppState> store) => _Props.fromStore(store),
      builder: (context, props) {
        return _Presenter(
          logout: props.logout,
          store: props.store
        );
      }
    );
  }
}

class _Presenter extends StatelessWidget {
  final Function logout;
  final MyStore.Store store;

  _Presenter({Key key, this.logout, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
          StoreBanner(),
          _title(),
          ListTile(
            title: Text('Show Store QR Code', style: TextStyle(fontSize: 22.0)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => MyQrScreen(storeId: store.id)));
            },
          ),
          ListTile(
            title: Text('Update Store Details', style: TextStyle(fontSize: 22.0)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => UpdateStoreScreen()));
            },
          ),
          ListTile(
            title: Text('About', style: TextStyle(fontSize: 22.0)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AboutScreen()));
            },
          ),
          ListTile(
            title: Text('Contact Us', style: TextStyle(fontSize: 22.0)),
            onTap: () {
              launch(Utils.buildEmail('', ''));
            },
          ),
          ListTile(
            title: Text('Log out', style: TextStyle(fontSize: 22.0)),
            onTap: () {
              showDialog(context: context, builder: (context) => _logoutDialog(context));
            },
          ),
        ]),
      ),
    );
  }

  Widget _logoutDialog(context) {
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

  Widget _title() {
    return Padding(
      padding: EdgeInsets.only(left: 15.0, top: 30.0, bottom: 10.0),
      child: Text('Settings', style: Burnt.display4),
    );
  }
}

class _Props {
  final MyStore.Store store;
  final Function logout;

  _Props({this.store, this.logout});

  static fromStore(Store<AppState> store) {
    return _Props(
      store: store.state.me.store,
      logout: () => store.dispatch(Logout()),
    );
  }
}
