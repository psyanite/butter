import 'package:butter/models/post.dart';
import 'package:butter/models/reward.dart';
import 'package:butter/models/store.dart';
import 'package:butter/models/user.dart';
import 'package:butter/services/toaster.dart';

class MeService {
  const MeService();

  static Future<User> register(String email, String username, String password) async {
    String query = """
      mutation {
        addAdmin(email: "$email", username: "$username", password: "$password") {
          ${User.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['addAdmin'];
    return User.fromProfileToaster(json);
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    String query = """
      query {
        adminLogin(username: "$username", password: "$password") {
          ${User.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['adminLogin'];
    var admin = User.fromProfileToaster(json);
    var store = json != null ? Store.fromToaster(json['admin']['store']) : null;
    return { 'admin': admin, 'store': store };
  }

  static Future<Store> fetchStoreByAdminId(int adminId) async {
    String query = """
      query {
        adminById(id: $adminId) {
          store {
            ${Store.attributes}
          }
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['adminById'];
    return json != null ? Store.fromToaster(json['store']) : null;
  }

  static Future<int> getUserIdByUsername(String username) async {
    String query = """
      query {
        userProfileByUsername(username: "$username") {
          user_id
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['userProfileByUsername'];
    return json != null ? json['user_id'] : null;
  }

  static Future<int> getUserIdByEmail(String email) async {
    String query = """
      query {
        userAccountByEmail(email: "$email") {
          id
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['userAccountByEmail'];
    return json != null ? json['id'] : null;
  }

  static Future<List<Post>> fetchPostsByStoreId({int storeId, int limit, int offset}) async {
    String query = """
      query {
        postsByStoreId(storeId: $storeId, limit: $limit, offset: $offset) {
          ${Post.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['postsByStoreId'];
    return (json as List).map((p) => Post.fromToaster(p)).toList();
  }

  Future<List<Reward>> fetchRewardsByStoreId(int storeId) async {
    String query = """
      query {
        rewardsByStoreId(storeId: $storeId) {
          ${Reward.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['rewardsByStoreId'];
    return (json as List).map((p) => Reward.fromToaster(p)).toList();
  }

  Future<Store> fetchStoreById(int storeId) async {
    String query = """
      query {
        storeById(id: $storeId) {
          ${Store.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['storeById'];
    return Store.fromToaster(json);
  }

  static Future<bool> setCoverImage({storeId, pictureUrl}) async {
    String query = """
      mutation {
        setStoreCoverImage(storeId: $storeId, picture: "$pictureUrl") {
          cover_image
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['setStoreCoverImage'];
    return pictureUrl == json['cover_image'];
  }

  Future<bool> setFcmToken({userId, token}) async {
    String query = """
      mutation {
        setFcmToken(userId: $userId, token: "$token") {
          fcm_token
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['setFcmToken'];
    return token == json['fcm_token'];
  }
}
