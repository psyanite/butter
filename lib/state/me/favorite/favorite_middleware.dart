import 'package:butter/state/app/app_state.dart';
import 'package:butter/state/me/favorite/favorite_actions.dart';
import 'package:butter/state/me/favorite/favorite_service.dart';
import 'package:redux/redux.dart';

List<Middleware<AppState>> createFavoriteMiddleware([FavoriteService favoriteService = const FavoriteService()]) {
  final favoritePost = _favoritePost(favoriteService);
  final unfavoritePost = _unfavoritePost(favoriteService);
  final fetchFavorites = _fetchFavorites(favoriteService);

  return [
    TypedMiddleware<AppState, FavoritePost>(favoritePost),
    TypedMiddleware<AppState, UnfavoritePost>(unfavoritePost),
    TypedMiddleware<AppState, FetchFavorites>(fetchFavorites),
  ];
}

Middleware<AppState> _favoritePost(FavoriteService service) {
  return (Store<AppState> store, action, NextDispatcher next) {
//    store.dispatch(FavoritePostSuccess(action.postId));
//      service.favoritePost(userId: store.state.me.user.id, postId: action.postId).then((posts) {
//        store.dispatch(FetchFavoritesSuccess(favoritePosts: posts));
//    }).catchError((e) => store.dispatch(RequestFailure("favoritePost $e")));
    next(action);
  };
}

Middleware<AppState> _unfavoritePost(FavoriteService service) {
  return (Store<AppState> store, action, NextDispatcher next) {
//    store.dispatch(UnfavoritePostSuccess(action.postId));
//    service.unfavoritePost(userId: store.state.me.user.id, postId: action.postId).then((posts) {
//      store.dispatch(FetchFavoritesSuccess(favoritePosts: posts));
//    }).catchError((e) => store.dispatch(RequestFailure("unfavoritePost $e")));
    next(action);
  };
}

Middleware<AppState> _fetchFavorites(FavoriteService service) {
  return (Store<AppState> store, action, NextDispatcher next) {
//    var user = store.state.me.user;
//    if (user != null) {
//      service.fetchFavorites(user.id).then((map) {
//        List<int> postIds = map['postIds'];
//        store.dispatch(FetchFavoritesSuccess(
//          favoritePosts: postIds.toSet()));
//      }).catchError((e) => store.dispatch(RequestFailure("fetchFavorites $e")));
//    }
    next(action);
  };
}
