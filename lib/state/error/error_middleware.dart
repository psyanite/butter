import 'package:butter/services/log.dart';
import 'package:butter/state/app/app_state.dart';
import 'package:butter/state/error/error_actions.dart';
import 'package:butter/state/error/error_service.dart';
import 'package:redux/redux.dart';

List<Middleware<AppState>> createErrorMiddleware([ErrorService errorService = const ErrorService()]) {
  final sendSystemError = _sendSystemError(errorService);

  return [
    TypedMiddleware<AppState, SendSystemError>(sendSystemError),
  ];
}

Middleware<AppState> _sendSystemError(ErrorService service) {
  return (Store<AppState> store, action, NextDispatcher next) {
    service.addSystemError(action.type, action.description).then((result) {
      if (result == false) store.dispatch(RequestFailure('sendSystemError received false'));
    }).catchError((e, stack) {
      Log.error('$e, $stack');
      store.dispatch(RequestFailure('sendSystemError $e'));
    });
    next(action);
  };
}
