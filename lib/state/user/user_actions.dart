import 'package:butter/models/user.dart';

class FetchUserByUserId {
  final int userId;

  FetchUserByUserId(this.userId);
}

class FetchUserByUserIdSuccess {
  final User user;

  FetchUserByUserIdSuccess(this.user);
}
