import 'package:butter/components/dialog/dialog.dart';
import 'package:butter/components/rewards/reward_locations_screen.dart';
import 'package:butter/models/reward.dart';
import 'package:butter/presentation/components.dart';
import 'package:butter/presentation/theme.dart';
import 'package:butter/utils/general_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class RewardScreen extends StatelessWidget {
  final Reward reward;

  RewardScreen({Key key, this.reward}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reward == null) return Scaffold(body: LoadingCenter());
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(child: _appBar()),
          SliverToBoxAdapter(child: _description()),
        ],
      )
    );
  }

  Widget _appBar() {
    return Column(
      children: <Widget>[
        Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: <Widget>[
            Container(
              height: 300.0,
              decoration: BoxDecoration(
                color: Burnt.imgPlaceholderColor,
                image: DecorationImage(
                  image: NetworkImage(reward.promoImage),
                  fit: BoxFit.cover,
                ),
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
            SafeArea(
              child: Container(
                height: 60.0,
                child: BackArrow(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _description() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Text(reward.name, style: Burnt.display4),
              ),
            ],
          ),
          Text(reward.bannerText()),
          Container(height: 30.0),
          if (reward.isHidden()) _secretBanner(),
          _locationDetails(),
          Container(height: 20.0),
          Text(reward.description),
          Container(height: 10.0),
          _termsAndConditions(),
          Container(height: 20.0),
          _qrCode(),
        ],
      ),
    );
  }

  Widget _secretBanner() {
    var onTap = (BuildContext context) {
      var options = <DialogOption>[DialogOption(display: 'OK', onTap: () => Navigator.of(context, rootNavigator: true).pop(true))];
      showDialog(
        context: context,
        builder: (context) {
          return BurntDialog(
            options: options,
            description:
                'Secret rewards do not show up when browsing the app, they can only be accessed via a shared link or a QR code. Save it to your favourites or you may not find it again!',
          );
        },
      );
    };
    return Builder(builder: (context) {
      return InkWell(
        onTap: () => onTap(context),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: Burnt.separator))),
          child: Row(
            children: <Widget>[
              Text('🎉', style: TextStyle(fontSize: 55.0)),
              Container(width: 15.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Congratulations!', style: TextStyle(fontWeight: Burnt.fontBold, color: Burnt.hintTextColor)),
                    Text('You\'ve unlocked a secret reward.'),
                    Text('Make sure you save it to your favourites!'),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _locationDetails() {
    if (reward.store != null) {
      return _storeInfo();
    } else {
      return _storeGroupDetails();
    }
  }

  Widget _storeInfo() {
    var store = reward.store;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Burnt.separator), bottom: BorderSide(color: Burnt.separator))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(store.name, style: TextStyle(fontSize: 20.0)),
          Container(height: 3.0),
          _address(),
        ],
      ),
    );
  }

  Widget _address() {
    var store = reward.store;
    var address = store.address;
    if (address == null) return Container();
    var first = store.getFirstLine();
    var second = store.getSecondLine();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (first.isNotEmpty) Text(first),
        if (second.isNotEmpty) Text(second),
      ],
    );
  }

  Widget _storeGroupDetails() {
    var group = reward.storeGroup;
    return Builder(builder: (context) {
      return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RewardLocationsScreen(group: group))),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: Burnt.separator), bottom: BorderSide(color: Burnt.separator))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(group.name, style: TextStyle(fontSize: 20.0)),
              Container(height: 7.0),
              Text('Available across ${group.stores.length.toString()} locations'),
              Container(height: 3.0),
              Text(group.stores.map((s) => s.location ?? s.suburb).join(', ')),
              Container(height: 10.0),
              Text('More Information', style: TextStyle(color: Burnt.primaryTextColor)),
            ],
          ),
        ),
      );
    });
  }

  Widget _termsAndConditions() {
    return Builder(builder: (context) {
      return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          var options = <DialogOption>[DialogOption(display: 'OK', onTap: () => Navigator.of(context, rootNavigator: true).pop(true))];
          showDialog(context: context, builder: (context) => TermsDialog(options: options, terms: reward.termsAndConditions));
        },
        child: Text(
          'Terms & Conditions',
          style: TextStyle(color: Burnt.primaryTextColor),
        ),
      );
    });
  }

  Widget _qrCode() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Burnt.separator))),
      child: Column(
        children: <Widget>[
          Center(
            child: QrImage(
              data: Utils.buildRewardQrCode(reward.code),
              size: 300.0,
              foregroundColor: Burnt.textBodyColor,
              version: 2,
            ),
          )
        ],
      ),
    );
  }
}
