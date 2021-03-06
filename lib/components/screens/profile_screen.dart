import 'dart:async';

import 'package:butter/components/post_list/post_list.dart';
import 'package:butter/components/screens/loading_screen.dart';
import 'package:butter/models/post.dart';
import 'package:butter/models/user.dart';
import 'package:butter/presentation/components.dart';
import 'package:butter/presentation/theme.dart';
import 'package:butter/state/app/app_state.dart';
import 'package:butter/state/post/post_service.dart';
import 'package:butter/state/user/user_actions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class ProfileScreen extends StatelessWidget {
  final int userId;

  ProfileScreen({Key key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, dynamic>(
      onInit: (Store<AppState> store) {
        if (store.state.user.users == null || store.state.user.users[userId] == null) {
          return store.dispatch(FetchUserByUserId(userId));
        }
      },
      converter: (Store<AppState> store) => _Props.fromStore(store, userId),
      builder: (context, props) => _Presenter(userId: userId, user: props.user),
    );
  }
}

class _Presenter extends StatefulWidget {
  final int userId;
  final User user;

  _Presenter({Key key, this.userId, this.user}) : super(key: key);

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

  Future<void> _refresh() async {
    var fresh = await PostService.fetchPostsByUserId(userId: widget.userId, limit: 12, offset: 0);
    this.setState(() {
      _limit = 12;
      _posts = fresh;
    });
  }

  _removeFromList(index, postId) {
    this.setState(() => _posts = List<Post>.from(_posts)..removeAt(index));
  }

  Future<List<Post>> _getPosts() async {
    var offset = _posts != null ? _posts.length : 0;
    return PostService.fetchPostsByUserId(userId: widget.userId, limit: _limit, offset: offset);
  }

  _getMorePosts() async {
    this.setState(() => _loading = true);
    var fresh = await _getPosts();
    if (fresh.length < _limit) {
      this.setState(() {
        _limit = 0;
        _loading = false;
      });
    }
    if (fresh.isNotEmpty) {
      var update = List<Post>.from(_posts)..addAll(fresh);
      this.setState(() {
        _posts = update;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = widget.user;
    if (user == null) return LoadingScreen();
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(slivers: <Widget>[
          _appBar(),
          PostList(
            noPostsView: Text('Looks like ${user.firstName} hasn\'t written any reviews yet.'),
            postListType: PostListType.forProfile,
            posts: _posts,
            removeFromList: _removeFromList,
          ),
          if (_loading == true) LoadingSliver(),
        ]),
      ),
    );
  }

  Widget _appBar() {
    var user = widget.user;
    return SliverToBoxAdapter(
      child: Column(children: <Widget>[
        Container(
          child: Stack(
            children: <Widget>[
              Container(height: 200.0),
              Stack(children: <Widget>[
                NetworkImg(user.profilePicture, height: 150.0),
                Container(
                  height: 150.0,
                  decoration: BoxDecoration(color: Color(0x55000000)),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(height: 55.0, child: BackArrow(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ]),
              Container(
                margin: EdgeInsets.only(top: 70.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[_profilePicture(user.profilePicture)],
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: <Widget>[
              Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Text(user.displayName, style: Burnt.titleStyle),
                Container(width: 4.0),
                Text('@${user.username}'),
              ]),
            ],
          ),
        ),
        if (user.tagline != null) _tagline(),
        Container(
          margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Burnt.separator))),
        )
      ]),
    );
  }

  Widget _tagline() {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 15.0),
      child: Text(widget.user.tagline),
    );
  }

  Widget _profilePicture(String picture) {
    return Container(
      width: 150.0,
      height: 150.0,
      decoration: BoxDecoration(
        color: Burnt.separator,
        borderRadius: BorderRadius.circular(150.0),
        border: Border.all(color: Colors.white, width: 4.0),
        image: DecorationImage(fit: BoxFit.fill, image: NetworkImage(picture)),
      ),
    );
  }
}

class _Props {
  final User user;

  _Props({this.user});

  static fromStore(Store<AppState> store, int userId) {
    return _Props(user: store.state.user.users[userId]);
  }
}
