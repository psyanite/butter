import 'package:butter/models/comment.dart';
import 'package:butter/models/post.dart';
import 'package:butter/services/toaster.dart';

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

  static Future<Post> updatePost(Post post) async {
    var body = post.postReview.body != null && post.postReview.body.isNotEmpty ? '"""${post.postReview.body}"""' : null;
    String query = """
      mutation {
        updatePost(
          id: ${post.id},
          hidden: false,
          body: $body,
          photos: [${post.postPhotos.map((p) => '"${p.url}"').join(', ')}],
        ) {
          ${Post.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['updatePost'];
    return Post.fromToaster(json);
  }

  static Future<Post> submitPost(Post post) async {
    var body = post.postReview.body != null && post.postReview.body.isNotEmpty ? '"""${post.postReview.body}"""' : null;
    String query = """
      mutation {
        addPost(
          hidden: false,
          official: true,
          storeId: ${post.store.id},
          body: $body,
          photos: [${post.postPhotos.map((p) => '"${p.url}"').join(', ')}],
          postedBy: ${post.postedBy.id}
        ) {
          ${Post.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['addPost'];
    return Post.fromToaster(json);
  }

  static Future<Post> fetchPostById(postId) async {
    String query = """
      query {
        postById(id: $postId) {
          ${Post.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['postById'];
    return Post.fromToaster(json);
  }

  static Future<Map<String, dynamic>> fetchPostByIdWithComments(postId) async {
    String query = """
      query {
        postById(id: $postId) {
          ${Post.attributes}
          comments {
            ${Comment.attributes}
          }
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['postById'];
    var comments = json == null ? null
      : (json['comments'] as List).map((c) => Comment.fromToaster(c)).toList();
    return { 'post': Post.fromToaster(json), 'comments': comments };
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
