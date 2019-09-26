import 'package:butter/components/dialog/dialog.dart';
import 'package:butter/components/honor/honor_success_screen.dart';
import 'package:butter/components/honor/scan_reward_screen.dart';
import 'package:butter/models/reward.dart';
import 'package:butter/models/user_reward.dart';
import 'package:butter/presentation/components.dart';
import 'package:butter/presentation/crust_cons_icons.dart';
import 'package:butter/presentation/theme.dart';
import 'package:butter/state/reward/reward_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';

class HonorRewardScreen extends StatefulWidget {
  final UserReward userReward;

  HonorRewardScreen({Key key, this.userReward}) : super(key: key);

  @override
  _HonorRewardScreenState createState() => _HonorRewardScreenState();
}

class _HonorRewardScreenState extends State<HonorRewardScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    var slivers = <Widget>[_appBar(), _content(context)];
    return Scaffold(body: CustomScrollView(slivers: slivers));
  }

  Widget _appBar() {
    var title = _actionText() == 'Give New Loyalty Card' ? 'Loyalty Reward Unlocked' : _actionText();
    return SliverSafeArea(
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 35.0, bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(width: 50.0, height: 60.0),
                  Positioned(left: -12.0, child: BackArrow(color: Burnt.lightGrey, onTap: _goBack)),
                ],
              ),
              Column(
                children: <Widget>[
                  Text(title.toString().toUpperCase(), style: Burnt.appBarTitleStyle),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(children: <Widget>[
          _UserRewardInfo(userReward: widget.userReward),
          Container(height: 20.0),
          _buttons(),
        ]),
      ),
    );
  }

  Widget _buttons() {
    return Builder(builder: (context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _cancelText(),
          Container(width: 20.0),
          if (_loading == true) _loadingIcon() else _submitButton(context),
        ],
      );
    });
  }

  Widget _loadingIcon() {
    return Container(padding: EdgeInsets.symmetric(horizontal: 35.0), child: CircularProgressIndicator());
  }

  Widget _submitButton(context) {
    var giveReward = _actionText() == 'Give New Loyalty Card';
    return SmallSolidButton(
      color: giveReward ? Color(0xDD007AFF) : Burnt.primary,
      onPressed: () => _awardStar(context),
      padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 10.0, bottom: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (giveReward) _presentIcon(),
          Text(_actionText(), style: TextStyle(fontSize: 22.0, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _presentIcon() {
    return Container(
      margin: EdgeInsets.only(right: 5.0),
      padding: EdgeInsets.only(bottom: 3.0),
      child: Icon(CrustCons.present, color: Colors.white, size: 30.0),
    );
  }

  _awardStar(context) async {
    this.setState(() => _loading = true);
    var result = await RewardService.honorUserReward(widget.userReward.uniqueCode);
    var error = result['error'];
    if (error != null) {
      snack(context, 'Error: $error');
      this.setState(() => _loading = false);
      return;
    }
    var fresh = result['userReward'] as UserReward;
    if (widget.userReward.uniqueCode != fresh.uniqueCode) {
      snack(context, 'Oops! Error 5001 occurred, please try again.');
      this.setState(() => _loading = false);
      return;
    }
    var clone = widget.userReward.copyWith(redeemedCount: fresh.redeemedCount, lastRedeemedAt: fresh.lastRedeemedAt);
    var newScreen = HonorSuccessScreen(userReward: clone, message: _getNewScreenMessage());
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => newScreen));
  }

  _getNewScreenMessage() {
    if (widget.userReward.isFullLoyaltyCard()) return 'New Loyalty Card Created';
    if (widget.userReward.reward.type == RewardType.loyalty) return 'Star Awarded Successfully';
    return 'Reward Honored Successfully';
  }

  Widget _cancelText() {
    return Builder(builder: (context) {
      return InkWell(
        onTap: () => _goBack(context),
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Text('Go Back', style: TextStyle(color: Burnt.hintTextColor, fontSize: 22.0)),
        ),
      );
    });
  }

  String _actionText() {
    var userReward = widget.userReward;
    if (userReward.reward.type != RewardType.loyalty) return 'Honor Reward';
    if (userReward.redeemedCount >= userReward.reward.redeemLimit) return 'Give New Loyalty Card';
    return 'Award Star';
  }

  _goBack(context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ScanRewardScreen()));
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
      Text(reward.name, overflow: TextOverflow.ellipsis, style: Burnt.titleStyle.copyWith(fontSize: 24.0)),
      Container(height: 10.0),
      Text(reward.typeText(), style: TextStyle(fontSize: 22.0)),
      Container(height: 20.0),
      Text(reward.description, textAlign: TextAlign.center, style: TextStyle(fontSize: 22.0)),
      Container(height: 10.0),
      _termsAndConditions(),
      if (reward.type == RewardType.loyalty) _loyaltyDetails(),
    ]);
  }

  Widget _loyaltyDetails() {
    var redeemedCount = userReward.redeemedCount;
    var limit = userReward.reward.redeemLimit;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
        redeemedCount == limit ? _allCollectedMessage() : Text('User has redeemed $redeemedCount / $limit stars.'),
      ],
    );
  }

  Widget _allCollectedMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[Text('🎉', style: TextStyle(fontSize: 55.0)), Container(width: 20.0), Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('All stars have been collected!'),
          Text('Honor customer with their loyalty reward.'),
        ],
      )],
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
