import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

@immutable
class FavoriteState {
  final Set<int> posts;

  FavoriteState({this.posts});

  FavoriteState.initialState()
    : posts = Set<int>();

  FavoriteState copyWith({
    Set<int> posts,
  }) {
    return FavoriteState(
      posts: posts ?? this.posts,
    );
  }
}
