class Rarity {
  final String id;
  final int normalCost;
  final int premiumCost;

  Map<String, int> qualities = {
    "regular": 0,
    "golden": 0,
    "diamond": 0,
    "signature": 0
  };

  Rarity(this.id, this.normalCost, this.premiumCost);

  void increment(bool normalCollectible, bool goldenCollectible, Map<String, int> qualities){
    if (normalCollectible)
      this.qualities["regular"] = this.qualities["regular"]! + qualities["regular"]!;
    for (var quality in qualities.entries.where((x) => x.key != "regular" && goldenCollectible)) {
      this.qualities[quality.key] = this.qualities[quality.key]! + quality.value;
    }
  }
  int getNormalCost() => qualities['regular']! * normalCost;
  int getNormalCount() => qualities['regular']!;
  int getPremiumCost() => (qualities['golden']! + qualities['signature']!) * premiumCost;
  int getPremiumCount() => qualities['golden']! + qualities['signature']!;

  Rarity.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      normalCost = json['normalCost'],
      premiumCost = json['premiumCost'],
      qualities = Map<String, int>.from(json['qualities']);

  Map<String, dynamic> toJson() => {
    'id': id,
    'normalCost': normalCost,
    'premiumCost': premiumCost,
    'qualities': qualities,
  };
}