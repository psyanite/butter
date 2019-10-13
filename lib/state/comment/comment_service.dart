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
        addStoreComment(postId: ${comment.postId}, body: "${comment.body}", storeId: ${comment.commentedByStore.id}) {
          ${Comment.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['addStoreComment'];
    return Comment.fromToaster(json);
  }

  static Future<bool> deleteComment({ storeId, comment }) async {
    String query = """
      mutation {
        deleteStoreComment(storeId: $storeId, commentId: ${comment.id}) {
          id
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['deleteStoreComment'];
    return json['id'] == comment.id;
  }

  static Future<Reply> addReply(Reply reply) async {
    String query = """
      mutation {
        addStoreReply(commentId: ${reply.commentId}, body: "${reply.body}", storeId: ${reply.repliedByStore.id}) {
          ${Reply.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['addStoreReply'];
    return Reply.fromToaster(json);
  }

  static Future<bool> deleteReply({ storeId, reply }) async {
    String query = """
      mutation {
        deleteStoreReply(storeId: $storeId, replyId: ${reply.id}) {
          id
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['deleteStoreReply'];
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
