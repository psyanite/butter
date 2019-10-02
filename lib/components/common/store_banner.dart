import 'package:butter/presentation/theme.dart';
import 'package:butter/state/app/app_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';


class StoreBanner extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, dynamic>(
      converter: (Store<AppState> store) => store.state.me?.store?.coverImage,
      builder: (context, image) {
        return Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            Container(
              height: 300.0,
              decoration: BoxDecoration(
                color: Burnt.imgPlaceholderColor,
                image: image != null ? DecorationImage(image: NetworkImage(image), fit: BoxFit.cover) : null,
              ),
            ),
            Container(
              height: 300.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.8],
                  colors: [Color(0x00000000), Color(0x30000000)],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
