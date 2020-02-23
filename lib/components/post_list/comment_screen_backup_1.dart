import 'dart:async';
import 'dart:collection';

import 'package:butter/components/dialog/confirm.dart';
import 'package:butter/components/post_list/comment_like_button.dart';
import 'package:butter/components/post_list/reply_like_button.dart';
import 'package:butter/components/screens/profile_screen.dart';
import 'package:butter/models/comment.dart';
import 'package:butter/models/post.dart';
import 'package:butter/models/reply.dart';
import 'package:butter/models/store.dart' as MyStore;
import 'package:butter/models/user.dart';
import 'package:butter/presentation/components.dart';
import 'package:butter/presentation/crust_cons_icons.dart';
import 'package:butter/presentation/theme.dart';
import 'package:butter/state/app/app_state.dart';
import 'package:butter/state/comment/comment_actions.dart';
import 'package:butter/state/comment/comment_service.dart';
import 'package:butter/utils/time_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:redux/redux.dart';

typedef SetReplyToComment = void Function(Comment comment, String replyTo, int replyToUserId);

class CommentScreen extends StatelessWidget {
  final Post post;
  final LinkedHashMap<int, Comment> comments;
  final bool showPostCard;
  final int flashComment;
  final int flashReply;

  CommentScreen({Key key, this.post, this.comments, this.showPostCard = false, this.flashComment, this.flashReply}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _Props>(
      onInit: (Store<AppState> store) {
        store.dispatch(FetchComments(post.id));
      },
      converter: (Store<AppState> store) => _Props.fromStore(store, post.id),
      builder: (BuildContext context, _Props props) {
        return _Presenter(
          post: post,
          showPostCard: showPostCard,
          comments: comments ?? props.comments,
          myId: props.myId,
          myStore: props.myStore,
          refresh: props.refresh,
          flashComment: flashComment,
          flashReply: flashReply,
        );
      },
    );
  }
}

class _Presenter extends StatefulWidget {
  final Post post;
  final bool showPostCard;
  final LinkedHashMap<int, Comment> comments;
  final int myId;
  final MyStore.Store myStore;
  final Function refresh;
  final int flashComment;
  final int flashReply;

  _Presenter(
      {Key key, this.post, this.showPostCard, this.comments, this.myId, this.myStore, this.refresh, this.flashComment, this.flashReply})
      : super(key: key);

  @override
  _PresenterState createState() => _PresenterState(comments: comments);
}

class _PresenterState extends State<_Presenter> {
  LinkedHashMap<int, Comment> comments;
  TextEditingController _bodyCtrl = TextEditingController();
  ScrollController _scrollie = ScrollController();
  String _body = '';
  FocusNode _bodyFocus;
  Form _form = Form(type: FormType.comment);
  bool _enableSubmit = false;
  String _replyTo;
  int _replyToUserId;
  bool _flashReplyTo = false;
  bool _showSpinner = false;
  int _flashComment;
  int _flashReply;

  _PresenterState({this.comments});

  @override
  initState() {
    super.initState();
    _bodyFocus = FocusNode();

    if (widget.flashComment != null || widget.flashReply != null) {
      Timer(Duration(milliseconds: 500), () {
        _flashSomething();
      });
    }
  }

  _flashSomething() {
    var flashComment = widget.flashComment;
    if (flashComment != null) {
      _flashComment = flashComment;
    }

    var flashReply = widget.flashReply;
    if (flashReply != null) {
      _flashReply = flashReply;
    }

    _scrollie.animateTo(
      _scrollie.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.ease,
    );

    Timer(Duration(seconds: 1), () {
      setState(() {
        _flashComment = null;
        _flashReply = null;
      });
    });
  }

  @override
  void didUpdateWidget(_Presenter old) {
    if (old.comments != widget.comments) {
      comments = widget.comments;
    }
    super.didUpdateWidget(old);
  }

  @override
  dispose() {
    _bodyCtrl.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(),
          Column(
            children: <Widget>[
              _appBar(context),
              _comments(),
            ],
          ),

          // Composer
          Positioned(
              bottom: 0.0,
              left: 0.0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Card(
                  color: Color(0xFFFDFDFD),
                  elevation: 24.0,
                  margin: EdgeInsets.all(0.0),
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0),
                    decoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _replyToField(),
                              _bodyTextField(context),
                              Container(height: 10.0),
                            ],
                          ),
                        ),
                        _submitButton(context),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _appBar(context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 35.0, bottom: 2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(width: 50.0, height: 60.0),
                Positioned(
                  left: -12.0,
                  child: IconButton(
                    icon: Icon(CrustCons.back, color: Burnt.lightGrey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            Text('COMMENTS', style: Burnt.appBarTitleStyle),
          ],
        ),
      ),
    );
  }

  Widget _noComments() {
    const text = 'Looks like there aren\'t any comments yet.\nBe the first to add one!';
    if (widget.showPostCard) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 30.0, bottom: 15.0),
          child: Text(text, textAlign: TextAlign.center),
        ),
      );
    }
    return Center(child: Text(text));
  }

  Widget _comments() {
    if (comments == null) return LoadingCenter();
    if (comments.isEmpty) return _noComments();

    var commentsArr = comments.values.toList();
    return Flexible(
      child: ScrollablePositionedList.builder(
        itemCount: commentsArr.length,
        itemBuilder: (context, i) {
          var comment = commentsArr[i];

//          return Text('hi');

          return Column(
            children: <Widget>[
              Text('fefe'),
              Text('fefe'),
              Row(
                children: <Widget>[
                  Text('1'),
                  Text('2'),
                  Expanded(
                    child: ScrollablePositionedList.builder(
                    itemCount: 2,
                    itemBuilder: (context, i) {
                      return Text('1');
                    },
                ),
                  )
                ],
//                child: ScrollablePositionedList.builder(
//                  itemCount: 2,
//                  itemBuilder: (context, i) {
//                    return Text('1');
//                  },
//                ),
              ),
            ],
//            child: Container(
//              child: ,
//            ),
          );

//          return _CommentCard(
//            postId: widget.post.id,
//            comment: comment,
//            setReplyToComment: _setReplyToComment,
//            removeComment: _removeComment,
//            removeReply: _removeReply,
//            myId: widget.myId,
//            flash: _flashComment == comment.id,
//            flashReply: _flashReply,
//          );
        },
      ),
    );
  }

  Widget _replyToField() {
    var text = _replyTo != null ? 'Reply to $_replyTo' : _form.comment != null ? 'Reply to ${_form.comment.replyTo()}' : 'Reply to post';
    return Builder(
      builder: (context) => Container(
        height: 25.0,
        child: Row(
          children: <Widget>[
            Text(text, style: TextStyle(color: _flashReplyTo ? Burnt.blue : Burnt.hintTextColor, fontSize: 13.0)),
            text != 'Reply to post'
                ? InkWell(
                    onTap: () => _setCommentToPost(context),
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.only(left: 3.0, right: 3.0, bottom: 1.0, top: 3.0),
                        child: Icon(CupertinoIcons.clear_thick_circled, size: 20.0, color: Burnt.lightGrey),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Widget _composer() {
    return Builder(
      builder: (context) => Card(
        color: Color(0xFFFDFDFD),
        elevation: 24.0,
        margin: EdgeInsets.all(0.0),
        child: Container(
            padding: EdgeInsets.only(left: 20.0),
            decoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
            child: Flexible(
              child: Row(children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _replyToField(),
//                      _bodyTextField(context),
                      Container(height: 10.0),
                    ],
                  ),
                )
              ]),
            )
            ),
      ),
    );
  }

  Widget _bodyTextField(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      reverse: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 50.0,
        ),
        child: TextField(
          focusNode: _bodyFocus,
          controller: _bodyCtrl,
          onChanged: _onBodyChange,
          onSubmitted: (text) => _handleSubmit(context, text),
          autofocus: true,
          maxLines: null,
          enabled: !_showSpinner,
          decoration: InputDecoration(contentPadding: EdgeInsets.all(0.0), border: InputBorder.none),
        ),
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    if (_showSpinner) {
      return Padding(
        padding: EdgeInsets.only(top: 18.0, right: 30.0, bottom: 20.0),
        child: SizedBox(
          width: 20.0,
          height: 20.0,
          child: CircularProgressIndicator(),
        ),
      );
    }

    return InkWell(
      highlightColor: Colors.transparent,
      child: Container(
          padding: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 16.0, right: 20.0),
          child: Text('Submit', style: TextStyle(color: _enableSubmit ? Burnt.primary : Burnt.lightBlue))),
      onTap: () => _handleSubmit(context, _bodyCtrl.text),
    );
  }

  _onBodyChange(String text) {
    setState(() {
      _body = text;
      _enableSubmit = text.trim().isNotEmpty;
    });
  }

  _doFlashReplyToField() {
    setState(() => _flashReplyTo = true);
    Future.delayed(Duration(milliseconds: 1000), () => setState(() => _flashReplyTo = false));
  }

  _scrollToBottom() {
    Timer(Duration(milliseconds: 500), () => _scrollie.jumpTo(_scrollie.position.maxScrollExtent));
  }

  _handleSubmit(BuildContext context, String text) async {
    if (widget.myId == null) snack(context, 'Login now to add comments');
    if (!_enableSubmit) return;
    this.setState(() => _showSpinner = true);
    _form.type == FormType.comment ? await _addComment() : await _addReply();
    this.setState(() => _showSpinner = false);
    FocusScope.of(context).requestFocus(FocusNode());
    _bodyCtrl.clear();
    _onBodyChange('');
  }

  _addComment() async {
    _scrollToBottom();
    var newComment = await CommentService.addComment(Comment(
      body: _body,
      postId: widget.post.id,
      commentedBy: User(id: widget.myId),
      commentedByStore: widget.myStore,
    ));

    widget.refresh();
    this.setState(() => _showSpinner = false);
    if (newComment != null) {
      var clone = LinkedHashMap<int, Comment>.from(comments);
      clone[newComment.id] = newComment;
      this.setState(() {
        comments = clone;
        _flashComment = newComment.id;
      });
    }
    _scrollToBottom();
  }

  _addReply() async {
    var body =
        _replyTo != null ? _replyTo.contains('@') ? '@${_replyTo.split('@')[1]} $_body' : '@${_replyTo.split(' ').join('')} $_body' : _body;

    var newReply = await CommentService.addReply(Reply(
      body: body,
      commentId: _form.comment.id,
      repliedBy: User(id: widget.myId),
      repliedByStore: widget.myStore,
      replyTo: _replyToUserId,
    ));

    widget.refresh();
    if (newReply != null) {
      var clone = LinkedHashMap<int, Comment>.from(comments);
      var cloneReplies = LinkedHashMap<int, Reply>.from(clone[newReply.commentId].replies);
      cloneReplies[newReply.id] = newReply;
      clone[newReply.commentId] = clone[newReply.commentId].copyWith(replies: cloneReplies);
      this.setState(() => comments = clone);
    }
  }

  _removeReply(Reply reply) {
    var clone = LinkedHashMap<int, Comment>.from(comments);
    clone[reply.commentId].replies.remove(reply.id);
    this.setState(() => comments = clone);
  }

  _removeComment(Comment comment) {
    this.setState(() => comments = LinkedHashMap<int, Comment>.from(comments)..remove(comment.id));
  }

  _setCommentToPost(BuildContext context) {
    setState(() {
      _form = Form(type: FormType.comment);
      _replyTo = null;
    });
    FocusScope.of(context).requestFocus(_bodyFocus);
    _doFlashReplyToField();
  }

  _setReplyToComment(Comment comment, String replyTo, int replyToUserId) {
    setState(() {
      _form = Form(type: FormType.reply, comment: comment);
      _replyTo = replyTo;
      _replyToUserId = replyToUserId;
    });
    FocusScope.of(context).requestFocus(_bodyFocus);
    _doFlashReplyToField();
  }
}

class _CommentCard extends StatefulWidget {
  final int postId;
  final Comment comment;
  final SetReplyToComment setReplyToComment;
  final Function removeComment;
  final Function removeReply;
  final int myId;
  final bool flash;
  final int flashReply;

  _CommentCard(
      {Key key,
      this.postId,
      this.comment,
      this.setReplyToComment,
      this.removeComment,
      this.removeReply,
      this.myId,
      this.flash,
      this.flashReply})
      : super(key: key);

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<_CommentCard> with TickerProviderStateMixin {
  bool _showReplies = false;
  AnimationController _colorCtrl;
  Animation<Color> _colorTween;

  @override
  void didUpdateWidget(_CommentCard old) {
    if (old.comment.replies.length < widget.comment.replies.length) {
      _showReplies = true;
    }
    super.didUpdateWidget(old);
  }

  @override
  initState() {
    super.initState();
    _colorCtrl = AnimationController(duration: Duration(seconds: 1), vsync: this);
    _colorTween = ColorTween(begin: widget.flash ? Burnt.primaryLight : Burnt.paper).animate(_colorCtrl);
    if (widget.flash) _colorCtrl.forward();

    if (widget.comment.replies.values.map((r) => r.id).contains(widget.flashReply)) {
      _showReplies = true;
    }
  }

  @override
  dispose() {
    _colorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var comment = widget.comment;
    return AnimatedBuilder(
      animation: _colorTween,
      builder: (context, child) => Container(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onLongPress: () async {
            if (widget.myId != widget.comment.commentedBy?.id) return;
            _colorTween = ColorTween(begin: Burnt.primaryLight).animate(_colorCtrl);
            Future.delayed(Duration(milliseconds: 500), () {
              var deleteComment = () async {
                var success = await CommentService.deleteComment(userId: widget.myId, comment: comment);
                if (success == true) {
                  widget.removeComment(comment);
                  snack(context, 'Comment deleted successfully');
                }
              };
              showDialog(context: context, builder: (context) => _deleteDialog(context, deleteComment));
            });
            await _colorCtrl.forward();
            _colorTween = ColorTween(begin: Burnt.paper).animate(_colorCtrl);
            _colorCtrl.reset();
          },
          child: Container(
            color: _colorTween.value,
            padding: EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              _profilePicture(context, comment.commentedBy, comment.commentedByStore),
              _body(),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    var comment = widget.comment;
    var commentedAt = TimeUtil.format(comment.commentedAt);
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _commentedBy(),
                      Text(comment.body),
                      Row(
                        children: <Widget>[
                          Text('$commentedAt ·', style: TextStyle(color: Burnt.lightTextColor, fontSize: 15.0)),
                          InkWell(
                            splashColor: Burnt.primaryLight,
                            onTap: _onTapReply,
                            child: Container(
                              padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Text(' Reply', style: TextStyle(color: Burnt.lightTextColor, fontSize: 15.0)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                CommentLikeButton(comment: comment)
              ],
            ),
          ),
          comment.replies.isNotEmpty ? _replyTeaser() : Container(height: 15.0),
          if (comment.replies.isNotEmpty && _showReplies)
            _Replies(
              postId: widget.postId,
              comment: comment,
              replies: comment.replies.values.toList(),
              myId: widget.myId,
              setReplyToComment: widget.setReplyToComment,
              removeReply: widget.removeReply,
              flashReply: widget.flashReply,
            ),
        ],
      ),
    );
  }

  Widget _commentedBy() {
    var comment = widget.comment;
    var commentedBy = comment.commentedBy;
    var store = comment.commentedByStore;
    var goto = _goto(commentedBy, store);
    var onTap = () {
      if (goto != null) Navigator.push(context, MaterialPageRoute(builder: (_) => goto));
    };

    return InkWell(
      onTap: onTap,
      child: store != null ? _byStore(store) : _byUser(commentedBy),
    );
  }

  Widget _replyTeaser() {
    var text = _showReplies ? 'Hide replies' : 'Show ${widget.comment.replies.length} replies';
    return Flexible(
      child: Builder(
        builder: (context) => InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 7.0),
            child: Row(children: <Widget>[
              Expanded(child: Divider()),
              Container(width: 15.0),
              Text(text, style: TextStyle(color: Burnt.hintTextColor, fontSize: 15.0)),
              Container(width: 15.0),
              Expanded(child: Divider()),
            ]),
          ),
          onTap: () => this.setState(() => _showReplies = !_showReplies),
        ),
      ),
    );
  }

  _onTapReply() {
    var comment = widget.comment;
    widget.setReplyToComment(comment, null, comment.commentedBy.id);
  }
}

class _Replies extends StatefulWidget {
  final int postId;
  final Comment comment;
  final List<Reply> replies;
  final int myId;
  final SetReplyToComment setReplyToComment;
  final Function removeReply;
  final int flashReply;

  _Replies({Key key, this.postId, this.comment, this.replies, this.myId, this.setReplyToComment, this.removeReply, this.flashReply})
      : super(key: key);

  @override
  _RepliesState createState() => _RepliesState();
}

class _RepliesState extends State<_Replies> {
  bool _flashLastReply = false;
  final _scrollie = ItemScrollController();

  @override
  void didUpdateWidget(_Replies old) {
    if (widget.replies.length > old.replies.length) {
      _flashLastReply = true;
      _scrollTo(widget.replies.length);
    }
    super.didUpdateWidget(old);
  }

  @override
  void initState() {
    super.initState();

    if (widget.flashReply != null) {
      _scrollToFlashReply();
    }
  }

  _scrollToFlashReply() {
    var reply = widget.replies.firstWhere((r) => r.id == widget.flashReply, orElse: null);
    if (reply != null) {
      _scrollTo(reply.id);
    }
  }

  _scrollTo(int index) {
//    Timer(Duration(milliseconds: 500), () {
//      _scrollie.scrollTo(
//        index: index,
//        duration: Duration(milliseconds: 500),
//        curve: Curves.ease
//      );
//    });
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        child: ScrollablePositionedList.builder(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.only(top: 5.0, bottom: 15.0),
//        shrinkWrap: true,
//        physics: NeverScrollableScrollPhysics(),
          itemCount: widget.replies.length,
//        itemScrollController: _scrollie,
          itemBuilder: (context, i) {
            var reply = widget.replies[i];
            return _ReplyCard(
              postId: widget.postId,
              reply: reply,
              myId: widget.myId,
              flash: (reply.id == widget.flashReply) || (_flashLastReply && i == widget.replies.length - 1),
              onTapReply: _onTapReply,
              removeReply: widget.removeReply,
            );
          },
        ),
      ),
    );


    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Flexible(
        child: ScrollablePositionedList.builder(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.only(top: 5.0, bottom: 15.0),
//        shrinkWrap: true,
//        physics: NeverScrollableScrollPhysics(),
          itemCount: widget.replies.length,
//        itemScrollController: _scrollie,
          itemBuilder: (context, i) {
            var reply = widget.replies[i];
            return _ReplyCard(
              postId: widget.postId,
              reply: reply,
              myId: widget.myId,
              flash: (reply.id == widget.flashReply) || (_flashLastReply && i == widget.replies.length - 1),
              onTapReply: _onTapReply,
              removeReply: widget.removeReply,
            );
          },
        ),
      ),
    );
  }

  _onTapReply(Reply reply) {
    widget.setReplyToComment(widget.comment, reply.getReplyTo(), reply.repliedBy.id);
  }
}

class _ReplyCard extends StatefulWidget {
  final int postId;
  final Reply reply;
  final int myId;
  final bool flash;
  final Function onTapReply;
  final Function removeReply;

  _ReplyCard({Key key, this.postId, this.reply, this.myId, this.flash, this.onTapReply, this.removeReply}) : super(key: key);

  @override
  _ReplyCardState createState() => _ReplyCardState();
}

class _ReplyCardState extends State<_ReplyCard> with TickerProviderStateMixin {
  AnimationController _colorCtrl;
  Animation<Color> _colorTween;

  @override
  initState() {
    super.initState();
    _colorCtrl = AnimationController(duration: Duration(seconds: 1), vsync: this);
    _colorTween = ColorTween(begin: widget.flash ? Burnt.primaryLight : Burnt.paper).animate(_colorCtrl);
    if (widget.flash) {
      Scrollable.ensureVisible(context);
      _colorCtrl.forward();
    }
  }

  @override
  dispose() {
    _colorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var reply = widget.reply;
    return AnimatedBuilder(
      animation: _colorTween,
      builder: (context, child) {
        return Container(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onLongPress: () async {
              if (widget.myId != reply.repliedBy?.id) return;
              _colorTween = ColorTween(begin: Burnt.primaryLight).animate(_colorCtrl);
              Future.delayed(Duration(milliseconds: 500), () {
                var deleteReply = () async {
                  var success = await CommentService.deleteReply(userId: widget.myId, reply: reply);
                  if (success == true) {
                    widget.removeReply(reply);
                    snack(context, 'Comment deleted successfully');
                  }
                };
                showDialog(context: context, builder: (context) => _deleteDialog(context, deleteReply));
              });
              await _colorCtrl.forward();
              _colorTween = ColorTween(begin: Burnt.paper).animate(_colorCtrl);
              _colorCtrl.reset();
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 7.0),
              color: _colorTween.value,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                _profilePicture(context, reply.repliedBy, reply.repliedByStore),
                body(),
                ReplyLikeButton(postId: widget.postId, reply: reply),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget body() {
    var reply = widget.reply;
    var repliedAt = TimeUtil.format(reply.repliedAt);
    return Expanded(
      flex: 1,
      child: Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _repliedBy(),
            _bodyText(reply.body),
            Row(
              children: <Widget>[
                Text('$repliedAt ·', style: TextStyle(color: Burnt.lightTextColor, fontSize: 15.0)),
                InkWell(
                  splashColor: Burnt.primaryLight,
                  onTap: () => widget.onTapReply(reply),
                  child: Text(' Reply', style: TextStyle(color: Burnt.lightTextColor, fontSize: 15.0)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _bodyText(String body) {
    if (body.startsWith('@') && body.indexOf(' ') > 0) {
      var mention = body.split(' ')[0];
      var content = body.substring(body.indexOf(' '));
      return RichText(
          text: TextSpan(
        style: TextStyle(color: Burnt.textBodyColor, fontFamily: Burnt.fontBase),
        children: <TextSpan>[
          TextSpan(text: mention, style: TextStyle(color: Burnt.darkBlue)),
          TextSpan(text: content),
        ],
      ));
    } else {
      return Text(body);
    }
  }

  Widget _repliedBy() {
    var reply = widget.reply;
    var repliedBy = reply.repliedBy;
    var store = reply.repliedByStore;
    var goto = _goto(repliedBy, store);
    var onTap = () {
      if (goto != null) Navigator.push(context, MaterialPageRoute(builder: (_) => goto));
    };

    return InkWell(
      onTap: onTap,
      child: store != null ? _byStore(store) : _byUser(repliedBy),
    );
  }
}

Widget _byUser(User user) {
  return Row(children: <Widget>[
    Text(user.displayName, style: TextStyle(fontWeight: FontWeight.bold)),
    Text(' @${user.username}', style: TextStyle(color: Burnt.hintTextColor, fontSize: 15.0))
  ]);
}

Widget _byStore(MyStore.Store store) {
  return Text(store.getStoreName(), style: TextStyle(fontWeight: FontWeight.bold));
}

Widget _goto(User user, MyStore.Store store) {
  return store == null ? ProfileScreen(userId: user.id) : null;
}

Widget _profilePicture(BuildContext context, User user, MyStore.Store store) {
  var image = user?.profilePicture ?? store.coverImage;
  var goto = _goto(user, store);
  var onTap = () {
    if (goto != null) Navigator.push(context, MaterialPageRoute(builder: (_) => goto));
  };

  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.only(top: 3.0, right: 10.0),
      child: NetworkImg(image, width: 30.0, height: 30.0),
    ),
  );
}

Widget _deleteDialog(BuildContext context, Function delete) {
  return Confirm(
    title: 'Would you like to delete your comment?',
    description: 'This comment will be lost forever.',
    action: 'Delete',
    onTap: () {
      delete();
      Navigator.of(context, rootNavigator: true).pop(true);
    },
  );
}

class _Props {
  final int myId;
  final MyStore.Store myStore;
  final LinkedHashMap<int, Comment> comments;
  final Function refresh;

  _Props({this.myId, this.myStore, this.comments, this.refresh});

  static fromStore(Store<AppState> store, int postId) {
    return _Props(
      myId: store.state.me.user?.id,
      myStore: store.state.me.store,
      comments: store.state.comment.comments[postId],
      refresh: () => store.dispatch(FetchComments(postId)),
    );
  }
}

enum FormType { reply, comment }

class Form {
  final FormType type;
  final Comment comment;

  Form({this.type, this.comment});
}
