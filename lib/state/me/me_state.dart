import 'dart:collection';

import 'package:butter/models/admin.dart';
import 'package:butter/models/post.dart';
import 'package:butter/models/reward.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:butter/models/store.dart' as MyStore;

@immutable
class MeState {
  final Admin admin;
  final MyStore.Store store;
  final LinkedHashMap<int, Post> posts;
  final LinkedHashMap<int, Reward> rewards;

  MeState({this.admin, this.store, this.posts, this.rewards});

  MeState.initialState()
      : admin = null,
        store = null,
        posts = LinkedHashMap<int, Post>(),
        rewards = LinkedHashMap<int, Reward>();

  MeState copyWith({
    Admin admin,
    MyStore.Store store,
    LinkedHashMap<int, Post> posts,
    LinkedHashMap<int, Reward> rewards,
  }) {
    return MeState(
      admin: admin ?? this.admin,
      store: store ?? this.store,
      posts: posts ?? this.posts,
      rewards: rewards ?? this.rewards,
    );
  }

  factory MeState.rehydrate(Map<String, dynamic> json) {
    var admin = json['admin'];
    return MeState.initialState().copyWith(admin: admin != null ? Admin.rehydrate(admin) : null);
  }

  Map<String, dynamic> toPersist() {
    return <String, dynamic>{
      'admin': this.admin?.toPersist(),
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
        admin: $admin, store: ${store != null ? store.id : null}, posts: ${posts.length}
      }''';
  }
}
