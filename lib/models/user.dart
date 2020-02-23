import 'package:butter/models/post.dart';
import 'package:butter/models/store.dart';

class User {
  final int id;
  final int adminId;
  final int storeId;
  final String username;
  final String firstName;
  final String lastName;
  final String displayName;
  final String email;
  final String profilePicture;
  final String tagline;
  final String fcmToken;
  final List<Post> posts;

  User({
    this.id,
    this.adminId,
    this.storeId,
    this.username,
    this.firstName,
    this.lastName,
    this.displayName,
    this.email,
    this.profilePicture,
    this.tagline,
    this.fcmToken,
    this.posts,
  });

  User copyWith({int id, String username, String profilePicture, String fcmToken, String storeId}) {
    return User(
      id: id ?? this.id,
      adminId: this.adminId,
      storeId: storeId ?? this.storeId,
      username: username ?? this.username,
      firstName: firstName,
      lastName: lastName,
      displayName: displayName,
      email: email,
      profilePicture: profilePicture ?? this.profilePicture,
      tagline: tagline,
      fcmToken: fcmToken ?? this.fcmToken,
      posts: posts,
    );
  }

  Map<String, dynamic> toPersist() {
    return <String, dynamic>{
      'id': this.id,
      'adminId': this.adminId,
      'storeId': this.storeId,
      'username': this.username,
      'firstName': this.firstName,
      'lastName': this.lastName,
      'email': this.email,
      'fcmToken': this.fcmToken,
    };
  }

  factory User.rehydrate(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      adminId: json['adminId'],
      storeId: json['storeId'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      fcmToken: json['fcmToken'],
    );
  }

  factory User.fromToaster(Map<String, dynamic> json) {
    if (json == null) return null;
    return User(
      id: json['id'],
      email: json['email'],
      username: json['profile']['username'],
      displayName: json['profile']['preferred_name'],
      profilePicture: json['profile']['profile_picture'],
      tagline: json['profile']['tagline'],
      posts: json['posts'] != null ? (json['posts'] as List).map((p) => Post.fromToaster(p)).toList() : null,
    );
  }

  factory User.fromProfileToaster(Map<String, dynamic> json) {
    if (json == null) return null;
    var admin = json['admin'];
    var account = json['user_account'];
    return User(
      id: json['user_id'],
      adminId: admin != null ? admin['id'] : null,
      storeId: admin != null ? admin['store_id'] : null,
      username: json['username'],
      displayName: json['preferred_name'],
      email: account != null ? account['email'] : null,
      profilePicture: json['profile_picture'],
      tagline: json['tagline'],
      fcmToken: json['fcmToken'],
    );
  }

  static const attributes = """
    user_id,
    admin {
      id,
      store {
        ${Store.attributes}
      },
    },
    username,
    first_name,
    last_name,
    user_account {
      email,
    },
    fcm_token,    
  """;

  bool isAdmin() {
    return storeId != null;
  }

  @override
  String toString() {
    return '{ id: $id, username: $username, storeId: $storeId }';
  }
}
