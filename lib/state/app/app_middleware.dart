import 'package:butter/state/app/app_state.dart';
import 'package:butter/state/comment/comment_middleware.dart';
import 'package:butter/state/me/me_middleware.dart';
import 'package:butter/state/user/user_middleware.dart';
import 'package:redux/redux.dart';

List<Middleware<AppState>> createAppMiddleware() {
  return <Middleware<AppState>>[]
    ..addAll(createMeMiddleware())
    ..addAll(createUserMiddleware())
    ..addAll(createCommentMiddleware())
    ..addAll(createUserMiddleware());
}
