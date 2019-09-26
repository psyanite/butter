import 'package:butter/components/dialog/dialog.dart';
import 'package:butter/components/honor/scan_reward_screen.dart';
import 'package:butter/models/reward.dart';
import 'package:butter/models/user_reward.dart';
import 'package:butter/presentation/components.dart';
import 'package:butter/presentation/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HonorSuccessScreen extends StatelessWidget {
  final UserReward userReward;
  final String message;

  HonorSuccessScreen({Key key, this.userReward, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: <Widget>[
        Flexible(
          child: CustomScrollView(slivers: <Widget>[
            SliverToBoxAdapter(
              child: Column(
                children: <Widget>[
                  Container(height: 100.0),
                  Text('Success', style: Burnt.titleStyle.copyWith(fontSize: 36.0)),
                  Container(height: 10.0),
                  Text(message, style: TextStyle(fontSize: 24.0)),
                  Container(height: 30.0),
                  _UserRewardInfo(userReward: userReward),
                ],
              ),
            )
          ]),
        ),
        _goAgainButton(),
      ]),
    );
  }

  Widget _goAgainButton() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Builder(builder: (context) {
        return BurntButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ScanRewardScreen()));
            },
            text: 'Go Back to Scanner');
      }),
    );
  }
}

class _UserRewardInfo extends StatelessWidget {
  final UserReward userReward;

  _UserRewardInfo({Key key, this.userReward}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var reward = userReward.reward;
    return Column(children: <Widget>[
      Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
          color: Burnt.imgPlaceholderColor,
          image: DecorationImage(
            image: NetworkImage(reward.promoImage),
            fit: BoxFit.cover,
          ),
        ),
      ),
      Container(height: 20.0),
      Text(reward.name, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 22.0)),
      Container(height: 10.0),
      Text(reward.typeText(), style: TextStyle(fontSize: 22.0)),
      Container(height: 20.0),
      _termsAndConditions(),
      if (reward.type == RewardType.loyalty) _loyaltyDetails(),
    ]);
  }

  Widget _loyaltyDetails() {
    var redeemedCount = userReward.redeemedCount;
    var limit = userReward.reward.redeemLimit;
    return Column(
      children: <Widget>[
        Container(height: 20.0),
        Container(
          height: _getStarHeight(limit),
          child: SvgPicture.asset(
            'assets/svgs/stars/${redeemedCount.toString()}-${limit.toString()}.svg',
            alignment: Alignment.center,
          ),
        ),
        Container(height: 20.0),
        if (redeemedCount != 0) Text('User has now redeemed $redeemedCount / $limit stars.'),
      ],
    );
  }

  Widget _termsAndConditions() {
    return Builder(builder: (context) {
      return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          var options = <DialogOption>[DialogOption(display: 'OK', onTap: () => Navigator.of(context, rootNavigator: true).pop(true))];
          showDialog(context: context, builder: (context) => TermsDialog(options: options, terms: userReward.reward.termsAndConditions));
        },
        child: Text('Terms & Conditions', style: TextStyle(color: Burnt.primaryTextColor, fontSize: 22.0)),
      );
    });
  }

  double _getStarHeight(limit) {
    switch (limit) {
      case 10:
        return 200.0;
      case 9:
        return 150.0;
      case 8:
        return 100.0;
      case 7:
        return 150.0;
      case 6:
        return 150.0;
      case 5:
        return 100.0;
      default:
        return 50.0;
    }
  }
}
