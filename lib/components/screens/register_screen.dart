import 'package:butter/main.dart';
import 'package:butter/presentation/components.dart';
import 'package:butter/state/app/app_state.dart';
import 'package:butter/state/me/me_actions.dart';
import 'package:butter/state/me/me_service.dart';
import 'package:butter/utils/general_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, dynamic>(
      converter: (Store<AppState> store) => (u, s) => store.dispatch(LoginSuccess(u, s)),
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
  String _confirmPw;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 0.6, 1.0],
                colors: [Color(0xFFffc86b), Color(0xFFffab40), Color(0xFFc45d35)],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Sign Up", style: TextStyle(fontSize: 24.0, color: Colors.white), textAlign: TextAlign.center),
                  Container(height: 20.0),
                  _textField('Username', (val) => setState(() => _un = val), false),
                  Container(height: 20.0),
                  _textField('Password', (val) => setState(() => _pw = val), true),
                  Container(height: 20.0),
                  _textField('Confirm Password', (val) => setState(() => _confirmPw = val), true),
                  Container(height: 30.0),
                  WhiteButton(text: "Sign Up", onPressed: () => _submit(context)),
                ],
              ),
            ),
          );
        },
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

  _submit(context) async {
    FocusScope.of(context).requestFocus(new FocusNode());
    var error = Utils.validateUsername(_un);
    if (error != null) {
      snack(context, error);
      return;
    }

    if (_pw.length < 8) {
      snack(context, 'Oops! Passwords must be more than 7 characters long');
      return;
    }

    if (_pw != _confirmPw) {
      snack(context, 'Oops! Passwords don\'t match');
      return;
    }

    var adminId = await MeService.getAdminIdByUsername(_un);
    if (adminId != null) {
      snack(context, 'Sorry, that username is already taken');
      return;
    }

    var result = await MeService.register(_un, _pw);
    var admin = result['admin'];
    var store = result['store'];

    if (admin == null) {
      snack(context, 'Oops! Something went wrong, please try again');
      return;
    }

    widget.loginSuccess(admin, store);
    Navigator.pushReplacementNamed(context, MainRoutes.home);
  }
}
