import 'package:butter/models/post.dart';

class FetchPostsForUser {
  final int userId;

  FetchPostsForUser(this.userId);
}

class FetchPostsForUserSuccess {
  final List<Post> posts;

  FetchPostsForUserSuccess(this.posts);
}
