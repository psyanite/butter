import 'package:butter/services/log.dart';
import 'package:butter/state/comment/comment_state.dart';
import 'package:butter/state/error/error_state.dart';
import 'package:butter/state/me/favorite/favorite_state.dart';
import 'package:butter/state/me/me_state.dart';
import 'package:butter/state/user/user_state.dart';
import 'package:meta/meta.dart';

@immutable
class AppState {
  final MeState me;
  final UserState user;
  final CommentState comment;
  final FavoriteState favorite;
  final ErrorState error;

  AppState({MeState me, UserState user, CommentState comment, FavoriteState favorite, ErrorState error})
      : me = me ?? MeState.initialState(),
        user = user ?? UserState.initialState(),
        comment = comment ?? CommentState.initialState(),
        favorite = favorite ?? FavoriteState.initialState(),
        error = error ?? ErrorState();

  static AppState rehydrate(dynamic json) {
    if (json == null) return AppState();
    try {
      return AppState(
        me: json['me'] != null ? MeState.rehydrate(json['me']) : MeState.initialState()
      );
    }
    catch (e, stack) {
      Log.error('Could not deserialize json from persistor: $e, $stack');
      return AppState();
    }
  }

  // Used by persistor
  Map<String, dynamic> toJson() => { 'me': me.toPersist() };

  AppState copyWith({MeState me}) {
    return AppState(me: me ?? this.me);
  }

  @override
  String toString() {
    return '''{
      me: $me,
      user: $user,
      comment: $comment,
      error: $error
    }''';
  }
}
