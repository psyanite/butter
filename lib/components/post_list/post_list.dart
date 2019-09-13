import 'package:butter/components/dialog/dialog.dart';
import 'package:butter/components/post_list/comment_screen.dart';
import 'package:butter/components/post_list/post_info.dart';
import 'package:butter/components/post_list/post_like_button.dart';
import 'package:butter/models/post.dart';
import 'package:butter/presentation/components.dart';
import 'package:butter/presentation/crust_cons_icons.dart';
import 'package:butter/presentation/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostList extends StatelessWidget {
  final Widget noPostsView;
  final PostListType postListType;
  final List<Post> posts;
  final Function removeFromList;

  PostList({Key key, this.noPostsView, this.postListType, this.posts, this.removeFromList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (posts == null) return LoadingSliverCenter();
    if (posts.isEmpty) return _noPosts();
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((builder, i) {
          var post = posts[i];
          return _PostCard(
            post: post,
            postListType: postListType,
            removeFromList: () => removeFromList(i, post.id),
          );
        }, childCount: posts.length),
      ),
    );
  }

  Widget _noPosts() {
    return SliverToBoxAdapter(
      child: Container(padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0), child: Center(child: noPostsView)),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final PostListType postListType;
  final Function removeFromList;

  _PostCard({Key key, this.post, this.postListType, this.removeFromList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PostInfo(post: post, postListType: postListType, buttons: _buttons());
  }

  List<Widget> _buttons() {
    var stuff = <Widget>[
      _postLikeButton(),
      _commentButton(),
    ];
    if (post.hidden == true) stuff.add(_secretIcon());
    return stuff;
  }

  Widget _postLikeButton() {
    return Padding(
      padding: EdgeInsets.only(top: 2.0),
      child: PostLikeButton(postId: post.id),
    );
  }

  Widget _commentButton() {
    return Builder(builder: (context) {
      return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(left: 10.0, right: 5.0),
          child: Row(children: <Widget>[
            Icon(CrustCons.post_comment, color: Burnt.iconGrey, size: 28.0),
            Container(width: 3.0),
            if (post.commentCount > 0) Text(post.commentCount.toString(), style: TextStyle(color: Burnt.lightTextColor, fontSize: 15.0)),
          ]),
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CommentScreen(post: post))),
      );
    });
  }

  Widget _secretIcon() {
    return Builder(builder: (context) {
      return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(left: 3.0, right: 5.0),
          child: Icon(CrustCons.padlock, color: Burnt.iconGrey, size: 28.0),
        ),
        onTap: () {
          var options = <DialogOption>[DialogOption(display: 'OK', onTap: () => Navigator.of(context, rootNavigator: true).pop(true))];
          showDialog(
            context: context,
            builder: (context) {
              return BurntDialog(
                options: options,
                description: 'This post is secret, only you can see it. You can make it public by editing the post.',
              );
            },
          );
        },
      );
    });
  }
}

enum PostListType { forStore, forProfile, forFeed }
