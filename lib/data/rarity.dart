import 'package:hs_stats/config.dart';
import 'package:hs_stats/data/card.dart';

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
  void increment(CardEntry card, Map<String, int> qualities){
    if (card.normalCollectible && !Config.uncollectibleRegulars.contains(card.name))
      this.qualities["regular"] = this.qualities["regular"]! + qualities["regular"]!;
    if(card.goldenCollectible && !Config.uncollectibleGoldens.contains(card.name))
      this.qualities["golden"] = this.qualities["golden"]! + qualities["golden"]!;
    if(card.goldenCollectible && !Config.uncollectibleSignatures.contains(card.name))
      this.qualities["signature"] = this.qualities["signature"]! + qualities["signature"]!;
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