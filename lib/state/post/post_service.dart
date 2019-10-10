import 'package:butter/models/post.dart';
import 'package:butter/services/toaster.dart';
import 'package:butter/utils/enum_util.dart';

class PostService {
  const PostService();

  static Future<bool> deletePhoto(int id) async {
    String query = """
      mutation {
        deletePhoto(id: $id) {
          id
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['deletePhoto'];
    return json['id'] == id;
  }

  static Future<bool> deletePost(int postId, int myId) async {
    String query = """
      mutation {
        deletePost(postId: $postId, myId: $myId) {
          id
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['deletePost'];
    return json['id'] == postId;
  }

  static Future<Post> updateReviewPost(Post post) async {
    var body = post.postReview.body != null && post.postReview.body.isNotEmpty ? '"""${post.postReview.body}"""' : null;
    String query = """
      mutation {
        updateAdminPost(
          id: ${post.id},
          body: $body,
          photos: [${post.postPhotos.map((p) => '"${p.url}"').join(", ")}],
        ) {
          ${Post.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['updateAdminPost'];
    return Post.fromToaster(json);
  }

  static Future<Post> submitPost(Post post) async {
    var body = post.postReview.body != null && post.postReview.body.isNotEmpty ? '"""${post.postReview.body}"""' : null;
    String query = """
      mutation {
        addAdminPost(
          storeId: ${post.store.id},
          body: $body,
          photos: [${post.postPhotos.map((p) => '"${p.url}"').join(", ")}],
          postedByAdmin: ${post.postedByAdmin.id}
        ) {
          ${Post.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['addAdminPost'];
    return Post.fromToaster(json);
  }

  static Future<List<Post>> fetchPostsByUserId({int userId, int limit, int offset}) async {
    String query = """
      query {
        postsByUserId(userId: $userId, limit: $limit, offset: $offset, showHiddenPosts: false) {
          ${Post.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['postsByUserId'];
    return (json as List).map((p) => Post.fromToaster(p)).toList();
  }

  static Future<List<Post>> fetchMyPosts({int userId, int limit, int offset}) async {
    String query = """
      query {
        postsByUserId(userId: $userId, limit: $limit, offset: $offset, showHiddenPosts: true) {
          ${Post.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['postsByUserId'];
    return (json as List).map((p) => Post.fromToaster(p)).toList();
  }
}
