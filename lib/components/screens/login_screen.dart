import 'package:butter/components/dialog/dialog.dart';
import 'package:butter/components/screens/privacy_screen.dart';
import 'package:butter/components/screens/register_screen.dart';
import 'package:butter/components/screens/terms_screen.dart';
import 'package:butter/main.dart';
import 'package:butter/presentation/components.dart';
import 'package:butter/presentation/theme.dart';
import 'package:butter/state/app/app_state.dart';
import 'package:butter/state/me/me_actions.dart';
import 'package:butter/state/me/me_service.dart';
import 'package:butter/utils/general_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, dynamic>(
      converter: (Store<AppState> store) => (u, s) {
        store.dispatch(LoginSuccess(u, s));
        store.dispatch(CheckFcmToken());
      },
      builder: (context, loginSuccess) => _Presenter(loginSuccess: loginSuccess),
    );
  }
}

class _Presenter extends StatefulWidget {
  final Function loginSuccess;

  _Presenter({Key key, this.loginSuccess}) : super(key: key);

  @override
  _PresenterState createState() => _PresenterState();
}

class _PresenterState extends State<_Presenter> {
  String _un;
  String _pw;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: Burnt.splashGradient,
        ),
        child: Builder(builder: (context) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: _content(context),
          );
        }),
      ),
    );
  }

  Widget _content(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset('assets/images/loading-icon.png', height: 200.0),
        Container(height: 20.0),
        _textField('Username', (val) => setState(() => _un = val), false),
        Container(height: 20.0),
        _textField('Password', (val) => setState(() => _pw = val), true),
        _forgotPassword(context),
        Container(height: 30.0),
        WhiteButton(text: 'Login', onPressed: () => _submit(context)),
        _signUp(context),
        _privacy(context),
      ],
    );
  }

  Widget _signUp(context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen())),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text('Don\'t have an account? ', style: TextStyle(color: Colors.white)),
          Text('Sign up now', style: TextStyle(color: Colors.white, decoration: TextDecoration.underline)),
        ]),
      ),
    );
  }

  Widget _textField(text, onChanged, obscure) {
    return TextField(
      onChanged: onChanged,
      obscureText: obscure,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: text,
        hintStyle: TextStyle(fontSize: 20.0, color: Color(0xDDFFFFFF)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x5AFFFFFF))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0x5AFFFFFF))),
      ),
      style: TextStyle(fontSize: 20.0, color: Color(0xFFFFFFFF)),
    );
  }

  Widget _forgotPassword(context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => _forgotDialog(context),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(height: 10.0),
          Text('Forgot Password', style: TextStyle(color: Color(0xDDFFFFFF))),
          Container(height: 5.0),
        ],
      ),
    );
  }

  Widget _forgotDialog(BuildContext context) {
    var close = () => Navigator.of(context, rootNavigator: true).pop(true);
    var send = () {
      launch(Utils.buildEmail('Forgot Password', 'Username: <please-enter-your-username>\n\nRequest for retrieving temporary password.'));
      close();
    };
    var options = <DialogOption>[
      DialogOption(display: 'Send Email', onTap: send),
      DialogOption(display: 'Cancel', onTap: close),
    ];
    return BurntDialog(
      options: options,
      title: 'Forgot Password',
      description: 'Please send an email with your username and we will sort it out as soon as possible.',
    );
  }

  Widget _privacy(context) {
    return Column(
      children: <Widget>[
        Text('By continuing you agree to our ', style: TextStyle(color: Colors.white)),
        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TermsScreen())),
            child: Text('Terms of Use', style: TextStyle(color: Colors.white, decoration: TextDecoration.underline)),
          ),
          Text(' and ', style: TextStyle(color: Colors.white)),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrivacyScreen())),
            child: Text('Privacy Policy', style: TextStyle(color: Colors.white, decoration: TextDecoration.underline)),
          ),
          Text('.', style: TextStyle(color: Colors.white))
        ])
      ],
    );
  }

  _submit(context) async {
    FocusScope.of(context).requestFocus(new FocusNode());
    var result = await MeService.login(_un, _pw);
    var admin = result['admin'];
    var store = result['store'];

    if (admin == null) {
      snack(context, 'Sorry, invalid username and password');
      return;
    }

    widget.loginSuccess(admin, store);
    Navigator.pushReplacementNamed(context, MainRoutes.splash);
  }
}
