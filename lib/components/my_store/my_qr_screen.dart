import 'package:butter/presentation/components.dart';
import 'package:butter/presentation/theme.dart';
import 'package:butter/utils/general_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyQrScreen extends StatelessWidget {
  final int storeId;

  MyQrScreen({Key key, this.storeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: Burnt.burntGradient,
        ),
        child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                QrImage(
                  data: Utils.buildStoreQrCode(storeId),
                  size: 300.0,
                  foregroundColor: Colors.white,
                  version: 2,
                ),
                Container(height: 10.0),
                Text('Here is the store QR code.', style: TextStyle(color: Colors.white, fontSize: 24.0)),
                Container(height: 30.0),
                WhiteBackButton(),
              ],
            ),
        ),
      ),
    );
  }
}
