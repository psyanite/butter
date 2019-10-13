import 'package:butter/models/comment.dart';
import 'package:butter/models/reply.dart';

class FetchComments {
  final int postId;

  FetchComments(this.postId);
}

class FetchCommentsSuccess {
  final int postId;
  final List<Comment> comments;

  FetchCommentsSuccess(this.postId, this.comments);
}

class FavoriteComment {
  final Comment comment;

  FavoriteComment(this.comment);
}

class FavoriteCommentSuccess {
  final int myStoreId;
  final Comment comment;

  FavoriteCommentSuccess(this.myStoreId, this.comment);
}

class UnfavoriteComment {
  final Comment comment;

  UnfavoriteComment(this.comment);
}

class UnfavoriteCommentSuccess {
  final int myStoreId;
  final Comment comment;

  UnfavoriteCommentSuccess(this.myStoreId, this.comment);
}

class FavoriteReply {
  final int postId;
  final Reply reply;

  FavoriteReply(this.postId, this.reply);
}

class FavoriteReplySuccess {
  final int myStoreId;
  final int postId;
  final Reply reply;

  FavoriteReplySuccess(this.myStoreId, this.postId, this.reply);
}

class UnfavoriteReply {
  final int postId;
  final Reply reply;

  UnfavoriteReply(this.postId, this.reply);
}

class UnfavoriteReplySuccess {
  final int myStoreId;
  final int postId;
  final Reply reply;

  UnfavoriteReplySuccess(this.myStoreId, this.postId, this.reply);
}
