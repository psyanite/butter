import 'package:butter/state/app/app_state.dart';
import 'package:butter/state/error/error_actions.dart';
import 'package:butter/state/me/me_actions.dart';
import 'package:butter/state/me/me_service.dart';
import 'package:redux/redux.dart';

List<Middleware<AppState>> createMeMiddleware([MeService meService = const MeService()]) {
  final fetchRewards = _fetchRewards(meService);

  return [
    TypedMiddleware<AppState, FetchRewards>(fetchRewards),
  ];
}

Middleware<AppState> _fetchRewards(MeService service) {
  return (Store<AppState> store, action, NextDispatcher next) {
    service.fetchRewardsByStoreId(action.storeId).then((rewards) {
      store.dispatch(FetchRewardsSuccess(rewards));
    }).catchError((e) => store.dispatch(RequestFailure("fetchRewards ${e.toString()}")));
    next(action);
  };
}
