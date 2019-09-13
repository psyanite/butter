import 'package:butter/state/app/app_state.dart';
import 'package:butter/state/comment/comment_reducer.dart';
import 'package:butter/state/error/error_reducer.dart';
import 'package:butter/state/me/me_reducer.dart';
import 'package:butter/state/user/user_reducer.dart';

AppState appReducer(AppState state, action) {
  return AppState(
    me: meReducer(state.me, action),
    user: userReducer(state.user, action),
    comment: commentReducer(state.comment, action),
    error: errorReducer(state.error, action),
  );
}
