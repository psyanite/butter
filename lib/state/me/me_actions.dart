import 'package:butter/models/admin.dart';
import 'package:butter/models/post.dart';
import 'package:butter/models/reward.dart';
import 'package:butter/models/store.dart';

class LoginSuccess {
  final Admin admin;
  final Store store;

  LoginSuccess(this.admin, this.store);
}

class Logout {}

class FetchStoreByAdminId {
  final int adminId;

  FetchStoreByAdminId(this.adminId);
}

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