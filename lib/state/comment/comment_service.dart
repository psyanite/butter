import 'package:butter/models/comment.dart';
import 'package:butter/models/reply.dart';
import 'package:butter/services/toaster.dart';

class CommentService {
  const CommentService();

  Future<List<Comment>> commentsByPostId(int postId) async {
    String query = """
      query {
        commentsByPostId(postId: $postId) {
          ${Comment.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['commentsByPostId'];
    return (json as List).map((c) => Comment.fromToaster(c)).toList();
  }

  static Future<Comment> addComment(Comment comment) async {
    String query = """
      mutation {
        addComment(
          postId: ${comment.postId}, 
          body: "${comment.body}", 
          commentedBy: ${comment.commentedBy.id},
          commentedByStore: ${comment.commentedByStore.id},
        ) {
          ${Comment.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['addComment'];
    return Comment.fromToaster(json);
  }

  static Future<bool> deleteComment({ userId, comment }) async {
    String query = """
      mutation {
        deleteComment(myId: $userId, commentId: ${comment.id}) {
          id
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['deleteComment'];
    return json['id'] == comment.id;
  }

  static Future<Reply> addReply(Reply reply) async {
    String query = """
      mutation {
        addReply(
          commentId: ${reply.commentId}, 
          body: "${reply.body}", 
          replyTo: ${reply.replyTo},
          repliedBy: ${reply.repliedBy.id}
          repliedByStore: ${reply.repliedByStore.id}
        ) {
          ${Reply.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['addReply'];
    return Reply.fromToaster(json);
  }

  static Future<bool> deleteReply({ userId, reply }) async {
    String query = """
      mutation {
        deleteReply(myId: $userId, replyId: ${reply.id}) {
          id
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['deleteReply'];
    return json['id'] == reply.id;
  }

  Future<bool> favoriteComment({ storeId, commentId }) async {
    String query = """
      mutation {
        favoriteCommentAsStore(storeId: $storeId, commentId: $commentId) {
          comment_id
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['favoriteCommentAsStore'];
    return json['comment_id'] == commentId;
  }

  Future<bool> unfavoriteComment({ storeId, commentId }) async {
    String query = """
      mutation {
        unfavoriteCommentAsStore(storeId: $storeId, commentId: $commentId) {
          comment_id
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['unfavoriteCommentAsStore'];
    return json['comment_id'] == commentId;
  }

  Future<bool> favoriteReply({ storeId, replyId }) async {
    String query = """
      mutation {
        favoriteReplyAsStore(storeId: $storeId, replyId: $replyId) {
          reply_id
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['favoriteReplyAsStore'];
    return json['reply_id'] == replyId;
  }

  Future<bool> unfavoriteReply({ storeId, replyId }) async {
    String query = """
      mutation {
        unfavoriteReplyAsStore(storeId: $storeId, replyId: $replyId) {
          reply_id
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['unfavoriteReplyAsStore'];
    return json['reply_id'] == replyId;
  }
}
