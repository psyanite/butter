

import 'package:butter/models/store.dart';

class Admin {
  final int id;
  final String username;

  Admin({
    this.id,
    this.username,
  });

  Map<String, dynamic> toPersist() {
    return <String, dynamic>{
      'id': this.id,
      'username': this.username,
    };
  }

  factory Admin.rehydrate(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      username: json['username'],
    );
  }

  factory Admin.fromToaster(Map<String, dynamic> json) {
    if (json == null) return null;
    return Admin(
      id: json['id'],
      username: json['username'],
    );
  }


  static const attributes = """
    id,
    username,
    store {
      ${Store.attributes}
    }
  """;

  @override
  String toString() {
    return '{ id: $id, username: $username }';
  }
}
