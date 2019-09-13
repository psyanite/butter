import 'package:butter/components/my_store/set_picture_screen.dart';
import 'package:butter/presentation/components.dart';
import 'package:butter/presentation/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UpdateStoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var slivers = <Widget>[
      _appBar(),
      _options(context),
    ];
    return Scaffold(body: CustomScrollView(slivers: slivers));
  }

  Widget _appBar() {
    return SliverSafeArea(
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 35.0, bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(width: 50.0, height: 60.0),
                  Positioned(left: -12.0, child: BackArrow(color: Burnt.lightGrey)),
                ],
              ),
              Text('UPDATE STORE', style: Burnt.appBarTitleStyle)
            ],
          ),
        )),
    );
  }

  Widget _options(BuildContext context) {
    return SliverFillRemaining(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        ListTile(
          title: Text('Set store picture', style: TextStyle(fontSize: 18.0)),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => SetPictureScreen()));
          },
        ),
      ]),
    );
  }
}
