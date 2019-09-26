import 'package:butter/models/reward.dart';

class UserReward {
  final Reward reward;
  final int userId;
  final int rewardId;
  final String uniqueCode;
  final DateTime lastRedeemedAt;
  final int redeemedCount;

  UserReward({
    this.reward,
    this.userId,
    this.rewardId,
    this.uniqueCode,
    this.lastRedeemedAt,
    this.redeemedCount,
  });

  UserReward copyWith({Reward reward, int userId, int rewardId, String uniqueCode, DateTime lastRedeemedAt, int redeemedCount}) {
    return UserReward(
      reward: reward ?? this.reward,
      userId: userId ?? this.userId,
      rewardId: rewardId ?? this.rewardId,
      uniqueCode: uniqueCode ?? this.uniqueCode,
      lastRedeemedAt: lastRedeemedAt ?? this.lastRedeemedAt,
      redeemedCount: redeemedCount ?? this.redeemedCount,
    );
  }

  bool isFullLoyaltyCard() {
    return reward.type == RewardType.loyalty && redeemedCount >= reward.redeemLimit;
  }

  factory UserReward.fromToaster(Map<String, dynamic> json) {
    if (json == null) return null;
    return UserReward(
      reward: json['reward'] != null ? Reward.fromToaster(json['reward']) : null,
      userId: json['user_id'],
      rewardId: json['reward_id'],
      uniqueCode: json['unique_code'],
      lastRedeemedAt: json['last_redeemed_at'] != null ? DateTime.parse(json['last_redeemed_at']) : null,
      redeemedCount: json['redeemed_count'],
    );
  }

  static const attributes = """
    user_id,
    reward_id,
    unique_code,
    last_redeemed_at,
    redeemed_count
  """;

  @override
  String toString() {
    return '{ userId: $userId, rewardId: $rewardId, code: $uniqueCode, lastRedeemedAt: $lastRedeemedAt, redeemedCount: $redeemedCount }';
  }
}
