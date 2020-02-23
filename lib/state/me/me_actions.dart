import 'package:butter/models/post.dart';
import 'package:butter/models/reward.dart';
import 'package:butter/models/store.dart';
import 'package:butter/models/user.dart';

class LoginSuccess {
  final User user;
  final Store store;

  LoginSuccess(this.user, this.store);
}

class Logout {}

class FetchRewards {
  final int storeId;

  FetchRewards(this.storeId);
}

class FetchRewardsSuccess {
  final List<Reward> rewards;

  FetchRewardsSuccess(this.rewards);
}

class FetchStoreSuccess {
  final Store store;

  FetchStoreSuccess(this.store);
}

class FetchPostsSuccess {
  final List<Post> posts;

  FetchPostsSuccess(this.posts);
}

class ClearPosts {}

class SetCoverImage {
  final String picture;

  SetCoverImage(this.picture);
}

class CheckFcmToken {
  CheckFcmToken();
}

class SetFcmToken {
  final String token;

  SetFcmToken(this.token);
}
