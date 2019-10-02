import 'package:butter/components/common/store_banner.dart';
import 'package:butter/components/my_store/set_picture_screen.dart';
import 'package:butter/presentation/components.dart';
import 'package:butter/presentation/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UpdateStoreScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
          _appBar(),
          _title(),
          ListTile(
            title: Text('Set store picture', style: TextStyle(fontSize: 22.0)),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SetPictureScreen()));
            },
          ),
        ]),
      ),
    );
  }

  Widget _appBar() {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: <Widget>[
        StoreBanner(),
        Container(height: 60.0, child: BackArrow(color: Colors.white)),
      ],
    );
  }

  Widget _title() {
    return Padding(
      padding: EdgeInsets.only(left: 15.0, top: 30.0, bottom: 10.0),
      child: Text('Update Store Details', style: Burnt.display4),
    );
  }
}
