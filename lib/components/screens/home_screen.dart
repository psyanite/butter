import 'dart:async';

import 'package:butter/components/common/store_banner.dart';
import 'package:butter/components/new_post/new_post_screen.dart';
import 'package:butter/components/post_list/post_list.dart';
import 'package:butter/components/rewards/reward_swiper.dart';
import 'package:butter/models/post.dart';
import 'package:butter/models/reward.dart';
import 'package:butter/models/store.dart' as MyStore;
import 'package:butter/models/user.dart';
import 'package:butter/presentation/components.dart';
import 'package:butter/presentation/crust_cons_icons.dart';
import 'package:butter/presentation/theme.dart';
import 'package:butter/state/app/app_state.dart';
import 'package:butter/state/me/me_actions.dart';
import 'package:butter/state/me/me_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _Props>(
      onInit: (Store<AppState> store) {
        var s = store.state.me.store;
        if (s != null) store.dispatch(FetchRewards(s.id));
      },
      converter: (Store<AppState> store) => _Props.fromStore(store),
      builder: (BuildContext context, _Props props) {
        return _Presenter(
          store: props.store,
          rewards: props.rewards,
          logout: props.logout,
        );
      },
    );
  }
}

class _Presenter extends StatefulWidget {
  final MyStore.Store store;
  final List<Reward> rewards;
  final Function logout;

  _Presenter({Key key, this.store, this.rewards, this.logout}) : super(key: key);

  @override
  _PresenterState createState() => _PresenterState();
}

class _PresenterState extends State<_Presenter> {
  ScrollController _scrollie;
  List<Post> _posts;
  bool _loading = false;
  int _limit = 12;

  @override
  initState() {
    super.initState();
    _scrollie = ScrollController()
      ..addListener(() {
        if (_loading == false && _limit > 0 && _scrollie.position.extentAfter < 500) _getMorePosts();
      });
    _load();
  }

  @override
  dispose() {
    _scrollie.dispose();
    super.dispose();
  }

  _load() async {
    var fresh = await _getPosts();
    this.setState(() => _posts = fresh);
  }

  removeFromList(index, postId) {
    this.setState(() => _posts = List<Post>.from(_posts)..removeAt(index));
  }

  Future<List<Post>> _getPosts() async {
    var offset = _posts != null ? _posts.length : 0;
    return MeService.fetchPostsByStoreId(storeId: widget.store.id, limit: _limit, offset: offset);
  }

  _getMorePosts() async {
    this.setState(() => _loading = true);
    var fresh = await _getPosts();
    if (fresh.isEmpty) {
      this.setState(() {
        _limit = 0;
        _loading = false;
      });
      return;
    }
    var update = List<Post>.from(_posts)..addAll(fresh);
    this.setState(() {
      _posts = update;
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    var fresh = await MeService.fetchPostsByStoreId(storeId: widget.store.id, limit: 12, offset: 0);
    this.setState(() {
      _limit = 12;
      _posts = fresh;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.store == null) return Scaffold(body: LoadingCenter());
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: <Widget>[
            _appBar(),
            if (widget.rewards.isNotEmpty) _rewards(context),
            _newPostButton(context),
            PostList(
              noPostsView: Text('Looks like ${widget.store.name} doesn\'t have any reviews yet.'),
              postListType: PostListType.forStore,
              posts: _posts,
              removeFromList: removeFromList,
            ),
            if (_loading == true) LoadingSliver(),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return SliverToBoxAdapter(
      child: Container(
        child: Column(children: <Widget>[
          StoreBanner(),
          _metaInfo(),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Burnt.separator))),
          )
        ]),
      ),
    );
  }

  Widget _metaInfo() {
    var store = widget.store;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Text(store.name, style: Burnt.display4),
              ),
            ],
          ),
          Text(store.cuisines.join(', '), style: TextStyle(color: Burnt.primary)),
          Container(height: 35.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    InkWell(
                      splashColor: Burnt.splashOrange,
                      highlightColor: Colors.transparent,
                      onTap: () => launch('tel:${store.phoneNumber}'),
                      child: Row(
                        children: <Widget>[
                          Icon(CrustCons.call_bold, size: 35.0, color: Burnt.iconOrange),
                          Container(width: 10.0),
                          Text('${store.phoneNumber}', style: TextStyle(color: Burnt.hintTextColor)),
                        ],
                      ),
                    ),
                    Container(height: 10.0),
                    InkWell(
                      splashColor: Burnt.splashOrange,
                      highlightColor: Colors.transparent,
                      onTap: () => launch(store.getDirectionUrl()),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(CrustCons.location_bold, size: 35.0, color: Burnt.iconOrange),
                          Container(width: 10.0),
                          _addressLong(),
                        ],
                      ),
                    ),
                    Container(height: 5.0),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  _ratingCount(store.heartCount, Score.good),
                  _ratingCount(store.okayCount, Score.okay),
                  _ratingCount(store.burntCount, Score.bad),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _ratingCount(int count, Score score) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: Text(count != null ? count.toString() : '', style: TextStyle(color: Burnt.lightTextColor)),
          ),
          ScoreIcon(score: score, size: 25.0)
        ],
      ),
    );
  }

  Widget _addressLong() {
    var store = widget.store;
    var first = store.getFirstLine();
    var second = store.getSecondLine();
    return Flexible(
      child: Container(
        padding: EdgeInsets.only(right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (first.isNotEmpty) Text(first, style: TextStyle(color: Burnt.hintTextColor)),
            if (second.isNotEmpty) Text(second, style: TextStyle(color: Burnt.hintTextColor)),
          ],
        ),
      ),
    );
  }

  Widget _newPostButton(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(top: 33.0, bottom: 15.0, left: 16.0, right: 16.0),
        child: BurntButton(
          icon: CrustCons.new_post,
          iconSize: 25.0,
          text: 'New Post',
          padding: 15.0,
          fontSize: 20.0,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => NewPostScreen()));
          },
        ),
      ),
    );
  }

  Widget _rewards(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        child: Column(
          children: <Widget>[
            RewardSwiper(
              rewards: widget.rewards,
              header: Padding(
                padding: EdgeInsets.only(top: 50.0, bottom: 15.0),
                child: Text('REWARDS', style: Burnt.appBarTitleStyle.copyWith(color: Burnt.hintTextColor)),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Burnt.separator))),
            )
          ],
        ),
      ),
    );
  }
}

class _Props {
  final User me;
  final MyStore.Store store;
  final List<Reward> rewards;
  final Function logout;

  _Props({this.me, this.store, this.rewards, this.logout});

  static fromStore(Store<AppState> store) {
    return _Props(
      me: store.state.me.user,
      store: store.state.me.store,
      rewards: store.state.me.rewards.values.toList(),
      logout: () => store.dispatch(Logout()),
    );
  }
}
