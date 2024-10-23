import 'package:hs_stats/data/rarity.dart';

class Expansion {
  final String fullName;
  final String yearName;
  final String shortName;
  int? releaseYear;
  int? releaseMonth;

  Expansion(this.fullName, this.yearName, this.shortName, this.releaseYear, this.releaseMonth);
  
  final Map<String, Rarity> rarities = {
    "COMMON": Rarity("Common", 0, 2),
    "RARE": Rarity("Rare", 1, 5),
    "EPIC": Rarity("Epic", 5, 20),
    "LEGENDARY": Rarity("Legendary", 20, 80),
  };

  int sumAll() {
    int result = 0;
    for (var rarity in rarities.entries) {
      result += rarity.value.getNormalCost();
      result += rarity.value.getPremiumCost();
    }
    return result;
  }

  Expansion.fromJson(Map<String, dynamic> json)
    : fullName = json['fullName'],
      yearName = json['yearName'],
      shortName = json['shortName'],
      releaseYear = json['releaseYear'],
      releaseMonth = json['releaseMonth'] {
    rarities.clear();
    (json['rarities'] as Map<String, dynamic>?)?.forEach((key, value) {
      rarities[key] = Rarity.fromJson(value);
    });
  }
  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'yearName': yearName,
    'shortName': shortName,
    'releaseYear': releaseYear,
    'releaseMonth': releaseMonth,
    'rarities': rarities.map((key, value) => MapEntry(key, value.toJson())),
  };
}