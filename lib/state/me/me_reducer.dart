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
  new TypedReducer<MeState, SetCoverImage>(setCoverImage),
  new TypedReducer<MeState, SetFcmToken>(setFcmToken),
]);

MeState loginSuccess(MeState state, LoginSuccess action) {
  return MeState.initialState().copyWith(user: action.user, store: action.store);
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

MeState setCoverImage(MeState state, SetCoverImage action) {
  return state.copyWith(store: state.store.copyWith(coverImage: action.picture));
}

MeState setFcmToken(MeState state, SetFcmToken action) {
  return state.copyWith(user: state.user.copyWith(fcmToken: action.token));
}
