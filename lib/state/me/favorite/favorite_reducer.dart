import 'package:butter/state/me/favorite/favorite_actions.dart';
import 'package:butter/state/me/favorite/favorite_state.dart';
import 'package:redux/redux.dart';

Reducer<FavoriteState> favoriteReducer = combineReducers([
  new TypedReducer<FavoriteState, FavoritePostSuccess>(favoritePost),
  new TypedReducer<FavoriteState, UnfavoritePostSuccess>(unfavoritePost),
  new TypedReducer<FavoriteState, FetchFavoritesSuccess>(fetchFavorites),
]);

FavoriteState favoritePost(FavoriteState state, FavoritePostSuccess action) {
  return state.copyWith(posts: Set.from(state.posts)..add(action.postId));
}

FavoriteState unfavoritePost(FavoriteState state, UnfavoritePostSuccess action) {
  return state.copyWith(posts: Set.from(state.posts)..remove(action.postId));
}

FavoriteState fetchFavorites(FavoriteState state, FetchFavoritesSuccess action) {
  return state.copyWith(posts: action.favoritePosts);
}
