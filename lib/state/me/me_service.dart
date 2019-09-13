import 'package:butter/models/admin.dart';
import 'package:butter/models/post.dart';
import 'package:butter/models/reward.dart';
import 'package:butter/models/store.dart';
import 'package:butter/services/toaster.dart';

class MeService {
  const MeService();

  static Future<Map<String, dynamic>> register(String username, String password) async {
    String query = """
      mutation {
        addAdmin(username: "$username", password: "$password") {
          ${Admin.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['addAdmin'];
    var admin = Admin.fromToaster(json);
    var store = json != null ? Store.fromToaster(json['store']) : null;
    return { 'admin': admin, 'store': store };
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    String query = """
      query {
        adminLogin(username: "$username", password: "$password") {
          ${Admin.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['adminLogin'];
    var admin = Admin.fromToaster(json);
    var store = json != null ? Store.fromToaster(json['store']) : null;
    return { 'admin': admin, 'store': store };
  }

  Future<Store> fetchStoreByAdminId(int adminId) async {
    String query = """
      query {
        findAdminById(id: $adminId) {
          ${Admin.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['findAdminById'];
    return json != null ? Store.fromToaster(json['store']) : null;
  }

  static Future<int> getAdminIdByUsername(String username) async {
    String query = """
      query {
        findAdminByUsername(username: "$username") {
          id
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['findAdminByUsername'];
    var userId = json != null ? json['id'] : null;
    return userId;
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

  static Future<bool> setProfilePicture({userId, pictureUrl}) async {
    String query = """
      mutation {
        setStoreCoverImage(userId: $userId, picture: "$pictureUrl") {
          cover_image
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['setStoreCoverImage'];
    return pictureUrl == json['cover_image'];
  }
}
