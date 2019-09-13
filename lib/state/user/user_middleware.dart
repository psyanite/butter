import 'package:butter/state/app/app_state.dart';
import 'package:butter/state/error/error_actions.dart';
import 'package:butter/state/user/user_actions.dart';
import 'package:butter/state/user/user_service.dart';
import 'package:redux/redux.dart';

List<Middleware<AppState>> createUserMiddleware([
  UserService service = const UserService(),
]) {
  final fetchUserByUserId = _fetchUserByUserId(service);

  return [
    TypedMiddleware<AppState, FetchUserByUserId>(fetchUserByUserId),
  ];
}

Middleware<AppState> _fetchUserByUserId(UserService service) {
  return (Store<AppState> store, action, NextDispatcher next) {
    service.fetchUserByUserId(action.userId).then(
      (user) {
        store.dispatch(FetchUserByUserIdSuccess(user));
      },
    ).catchError((e) => store.dispatch(RequestFailure("fetchUserByUserId ${e.toString()}")));

    next(action);
  };
}
