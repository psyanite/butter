import 'package:butter/state/app/app_state.dart';
import 'package:butter/state/error/error_actions.dart';
import 'package:butter/state/me/me_actions.dart';
import 'package:butter/state/me/me_service.dart';
import 'package:redux/redux.dart';

List<Middleware<AppState>> createMeMiddleware([MeService meService = const MeService()]) {
  final fetchStoreByAdminId = _fetchStoreByAdminId(meService);
  final fetchRewards = _fetchRewards(meService);

  return [
    TypedMiddleware<AppState, FetchStoreByAdminId>(fetchStoreByAdminId),
    TypedMiddleware<AppState, FetchRewards>(fetchRewards),
  ];
}

Middleware<AppState> _fetchStoreByAdminId(MeService service) {
  return (Store<AppState> store, action, NextDispatcher next) {
    service.fetchStoreByAdminId(action.adminId).then((s) {
      store.dispatch(FetchStoreSuccess(s));
    }).catchError((e) => store.dispatch(RequestFailure("fetchStoreByAdminId ${e.toString()}")));
    next(action);
  };
}

Middleware<AppState> _fetchRewards(MeService service) {
  return (Store<AppState> store, action, NextDispatcher next) {
    service.fetchRewardsByStoreId(action.storeId).then((rewards) {
      store.dispatch(FetchRewardsSuccess(rewards));
    }).catchError((e) => store.dispatch(RequestFailure("fetchRewards ${e.toString()}")));
    next(action);
  };
}
