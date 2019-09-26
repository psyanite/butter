import 'package:butter/models/reward.dart';
import 'package:butter/models/user_reward.dart';
import 'package:butter/services/toaster.dart';

class RewardService {
  const RewardService();

  static Future<Map<String, dynamic>> canHonorUserReward(int adminId, String code) async {
    String query = """
      query {
        canHonorUserReward(adminId: $adminId, code: "$code") {
          reward {
            ${Reward.attributes}
          }
          ${UserReward.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var error = Toaster.getError(response);
    if (error != null) return {'error': error};

    var json = response['canHonorUserReward'];
    return {'userReward': UserReward.fromToaster(json)};
  }

  static Future<UserReward> fetchUserRewardByCode(String code) async {
    String query = """
      query {
        userRewardByCode(code: "$code") {
          reward {
            ${Reward.attributes}
          }
          ${UserReward.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var json = response['userRewardByCode'];
    return UserReward.fromToaster(json);
  }


  static Future<Map<String, dynamic>> honorUserReward(String code) async {
    String query = """
      mutation {
        honorReward(code: "$code") {
          ${UserReward.attributes}
        }
      }
    """;
    final response = await Toaster.get(query);
    var error = Toaster.getError(response);
    if (error != null) return {'error': error};

    var json = response['honorReward'];
    return {'userReward': UserReward.fromToaster(json)};
  }
}
