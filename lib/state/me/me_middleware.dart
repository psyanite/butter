import 'package:butter/services/firebase_messenger.dart';
import 'package:butter/state/app/app_state.dart';
import 'package:butter/state/error/error_actions.dart';
import 'package:butter/state/me/me_actions.dart';
import 'package:butter/state/me/me_service.dart';
import 'package:redux/redux.dart';

List<Middleware<AppState>> createMeMiddleware([MeService meService = const MeService()]) {
  final fetchRewards = _fetchRewards(meService);
  final setFcmToken = _setFcmToken(meService);

  return [
    TypedMiddleware<AppState, FetchRewards>(fetchRewards),
    TypedMiddleware<AppState, CheckFcmToken>(setFcmToken),
  ];
}

Middleware<AppState> _fetchRewards(MeService service) {
  return (Store<AppState> store, action, NextDispatcher next) {
    service.fetchRewardsByStoreId(action.storeId).then((rewards) {
      store.dispatch(FetchRewardsSuccess(rewards));
    }).catchError((e) => store.dispatch(RequestFailure('fetchRewards $e')));
    next(action);
  };
}

Middleware<AppState> _setFcmToken(MeService service) {
  return (Store<AppState> store, action, NextDispatcher next) {
    var currentToken = store.state.me.user?.fcmToken;
    FirebaseMessenger().getToken().then((t) {
      if (t == null) store.dispatch(SendSystemError('Get FCM Token', 'FCM returned null token ${store.state.me.user?.username}'));
      else if ((currentToken == null || t != currentToken)) {
        service.setFcmToken(userId: store.state.me.user.id, token: t).then((result) {
          if (result == true) {
            store.dispatch(SetFcmToken(t));
          } else {
            store.dispatch(RequestFailure('Set Fcm Token request result was false'));
          }
        }).catchError((e) => store.dispatch(RequestFailure('setFcmToken $e')));
      }
    }).catchError((e) => store.dispatch(SendSystemError('Get FCM Token', 'Error for ${store.state.me.user.username}, $e')));
    next(action);
  };
}
