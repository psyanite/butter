import 'dart:collection';

import 'package:butter/models/comment.dart';
import 'package:butter/models/reply.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

@immutable
class CommentState {
  final LinkedHashMap<int, LinkedHashMap<int, Comment>> comments;

  CommentState({this.comments});

  CommentState.initialState()
      : comments = LinkedHashMap<int, LinkedHashMap<int, Comment>>();

  CommentState copyWith({
    LinkedHashMap<int, LinkedHashMap<int, Comment>> comments,
  }) {
    return CommentState(
      comments: comments ?? this.comments,
    );
  }

  CommentState addComments(int postId, List<Comment> comments) {
    var clone = cloneComments();
    var newComments = LinkedHashMap<int, Comment>.fromEntries(comments.map((c) => MapEntry(c.id, c)));
    clone[postId] = newComments;
    return copyWith(comments: clone);
  }

  CommentState favoriteComment(int myStoreId, Comment comment) {
    var clone = cloneComments();
    clone[comment.postId][comment.id].likedByStores.add(myStoreId);
    return copyWith(comments: clone);
  }

  CommentState unfavoriteComment(int myStoreId, Comment comment) {
    var clone = cloneComments();
    clone[comment.postId][comment.id].likedByStores.remove(myStoreId);
    return copyWith(comments: clone);
  }

  CommentState favoriteReply(int myStoreId, int postId, Reply reply) {
    var clone = cloneComments();
    clone[postId][reply.commentId].replies[reply.id].likedByStores.add(myStoreId);
    return copyWith(comments: clone);
  }

  CommentState unfavoriteReply(int myStoreId, int postId, Reply reply) {
    var clone = cloneComments();
    clone[postId][reply.commentId].replies[reply.id].likedByStores.remove(myStoreId);
    return copyWith(comments: clone);
  }

  LinkedHashMap<int, LinkedHashMap<int, Comment>> cloneComments() {
    return LinkedHashMap<int, LinkedHashMap<int, Comment>>.from(this.comments);
  }

  @override
  String toString() {
    return '''{ comments: ${comments.length} }''';
  }

}
