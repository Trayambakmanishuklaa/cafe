class RewardModel {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final double discountAmount;
  final String rewardType;

  RewardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.discountAmount,
    required this.rewardType,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      pointsCost: json['pointsCost'] ?? 100,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      rewardType: json['rewardType'] ?? 'DISCOUNT_FLAT',
    );
  }
}

class LoyaltyTransactionModel {
  final String id;
  final String type;
  final int points;
  final String description;
  final DateTime createdAt;

  LoyaltyTransactionModel({
    required this.id,
    required this.type,
    required this.points,
    required this.description,
    required this.createdAt,
  });

  factory LoyaltyTransactionModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransactionModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'EARN',
      points: json['points'] ?? 0,
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class PassportDataModel {
  final int pointsBalance;
  final String tier;
  final int lifetimePoints;
  final int stampsCount;
  final List<LoyaltyTransactionModel> transactions;

  PassportDataModel({
    required this.pointsBalance,
    required this.tier,
    required this.lifetimePoints,
    required this.stampsCount,
    required this.transactions,
  });

  factory PassportDataModel.fromJson(Map<String, dynamic> json) {
    final account = json['account'] ?? {};
    final txList = (account['transactions'] as List<dynamic>?)
            ?.map((t) => LoyaltyTransactionModel.fromJson(t))
            .toList() ??
        [];

    return PassportDataModel(
      pointsBalance: account['pointsBalance'] ?? 0,
      tier: account['tier'] ?? 'BRONZE',
      lifetimePoints: account['lifetimePoints'] ?? 0,
      stampsCount: account['stampsCount'] ?? 0,
      transactions: txList,
    );
  }
}
