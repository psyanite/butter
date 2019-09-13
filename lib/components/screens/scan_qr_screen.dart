import 'package:butter/presentation/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScanQrScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ScanQrScreenState();
}

/// Example URLs:
/// https://burntoast.page.link/?link=https://burntoast.com/stores/?id=1
/// https://burntoast.page.link/?link=https://burntoast.com/profiles/?id=1
/// https://burntoast.page.link/?link=https://burntoast.com/rewards/?code=4pPfr
/// https://burntoast.page.link/?link=https://burntoast.com/rewards/?code=BKKWL
///
/// Example secret codes:
/// :stores:1
/// :profiles:1
/// :rewards:4pPfr
/// :rewards:BKKWL
class ScanQrScreenState extends State<ScanQrScreen> {
  String error;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (error == null) return Scaffold(body: LoadingCenter());
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(error),
            Container(height: 20.0),
            SmallButton(
              onPressed: () {
                this.setState(() => error = null);
              },
              padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 10.0, bottom: 10.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[Text('Try Again', style: TextStyle(fontSize: 16.0, color: Colors.white))],
              ),
            )
          ],
        ),
      ),
    );
  }
}
