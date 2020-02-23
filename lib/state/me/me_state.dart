import 'dart:collection';

import 'package:butter/models/post.dart';
import 'package:butter/models/reward.dart';
import 'package:butter/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:butter/models/store.dart' as MyStore;

@immutable
class MeState {
  final User user;
  final MyStore.Store store;
  final LinkedHashMap<int, Post> posts;
  final LinkedHashMap<int, Reward> rewards;

  MeState({this.user, this.store, this.posts, this.rewards});

  MeState.initialState()
      : user = null,
        store = null,
        posts = LinkedHashMap<int, Post>(),
        rewards = LinkedHashMap<int, Reward>();

  MeState copyWith({
    User user,
    MyStore.Store store,
    LinkedHashMap<int, Post> posts,
    LinkedHashMap<int, Reward> rewards,
  }) {
    return MeState(
      user: user ?? this.user,
      store: store ?? this.store,
      posts: posts ?? this.posts,
      rewards: rewards ?? this.rewards,
    );
  }

  factory MeState.rehydrate(Map<String, dynamic> json) {
    var user = json['user'];
    return MeState.initialState().copyWith(user: user != null ? User.rehydrate(user) : null);
  }

  Map<String, dynamic> toPersist() {
    return <String, dynamic>{
      'user': this.user?.toPersist(),
    };
  }

  MeState addPosts(List<Post> posts) {
    return copyWith(posts: clonePosts()..addEntries(posts.map((p) => MapEntry<int, Post>(p.id, p))));
  }

  MeState setRewards(List<Reward> rewards) {
    return copyWith(rewards: cloneRewards()..addEntries(rewards.map((r) => MapEntry<int, Reward>(r.id, r))));
  }

  LinkedHashMap<int, Post> clonePosts() {
    return LinkedHashMap<int, Post>.from(this.posts);
  }

  LinkedHashMap<int, Reward> cloneRewards() {
    return LinkedHashMap<int, Reward>.from(this.rewards);
  }

  @override
  String toString() {
    return '''{
        user: $user, store: ${store != null ? store.id : null}, posts: ${posts.length}
      }''';
  }
}
