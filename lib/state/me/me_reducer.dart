import 'dart:collection';

import 'package:butter/models/post.dart';
import 'package:butter/state/me/me_actions.dart';
import 'package:butter/state/me/me_state.dart';
import 'package:redux/redux.dart';

Reducer<MeState> meReducer = combineReducers([
  new TypedReducer<MeState, LoginSuccess>(loginSuccess),
  new TypedReducer<MeState, Logout>(logout),
  new TypedReducer<MeState, FetchStoreSuccess>(fetchStore),
  new TypedReducer<MeState, FetchPostsSuccess>(fetchPosts),
  new TypedReducer<MeState, FetchRewardsSuccess>(fetchRewards),
  new TypedReducer<MeState, SetMyProfilePicture>(setMyProfilePicture),
]);

MeState loginSuccess(MeState state, LoginSuccess action) {
  return MeState.initialState().copyWith(admin: action.admin, store: action.store);
}

MeState logout(MeState state, Logout action) {
  return MeState.initialState();
}

MeState clearPosts(MeState state, ClearPosts action) {
  return state.copyWith(posts: LinkedHashMap<int, Post>());
}

MeState fetchStore(MeState state, FetchStoreSuccess action) {
  return state.copyWith(store: action.store);
}

MeState fetchPosts(MeState state, FetchPostsSuccess action) {
  return state.addPosts(action.posts);
}

MeState fetchRewards(MeState state, FetchRewardsSuccess action) {
  return state.setRewards(action.rewards);
}

MeState setMyProfilePicture(MeState state, SetMyProfilePicture action) {
  return state.copyWith(store: state.store.copyWith(coverImage: action.picture));
}
