import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hs_stats/data/card.dart';
import 'package:hs_stats/data/collection.dart';

Future<Summary> fetchSummary(String session) async {
  var collectionFuture = fetchCollection(session);
  var cardsFuture = fetchCards();
  late CollectionData collection;
  late CardsData cards;

  await Future.wait([
    collectionFuture.then((value) => collection = value),
    cardsFuture.then((value) => cards = value)
  ]);

  var summary = Summary();
  for (var entry in collection.collection) {
    var card = cards.cards[entry.cardId];
    if (card != null){
      if (summary.expansions.containsKey(card.set)){      
        summary.incrementStandard(card, entry.qualities);
      }
      else{
        summary.incrementWild(card, entry.qualities);
      }
    }
  }
  subtractUncollectibleSignature(summary);
  subtractUncollectibleInWild(summary);

  final cacheManager = DefaultCacheManager();
  cacheManager.putFile(
    'hearthstoneKey',
    utf8.encode(jsonEncode(summary)),
    fileExtension: 'json',
  );
  return summary;
}

class Summary {
   final Map<String, Expansion> expansions = {
    "WHIZBANGS_WORKSHOP": Expansion("Whizbang's Workshop", "Year of the Pegasus", "Whizbang", 2024, 3),
    "ISLAND_VACATION": Expansion("Perils in Paradise", "Year of the Pegasus", "Perils", 2024, 7),
    "_EXP3": Expansion("???", "Year of the Pegasus", "???", 2024, 11),

    "BATTLE_OF_THE_BANDS": Expansion("Festival of Legends", "Year of the Wolf", "Festival", 2023, 4),
    "TITANS": Expansion("Titans", 'Year of the Wolf', "Titans", 2023, 8),
    "WILD_WEST": Expansion("Showdown in the Badlands", "Year of the Wolf", "Badlands", 2023, 11),

    "WILD": Expansion("Wild", 'Wild', "Wild", null, null),
   };

   void incrementStandard(CardEntry card, Map<String, int> qualities)
    => expansions[card.set]
      !.rarities[card.rarity]
      !.increment(card.normalCollectible, card.goldenCollectible, qualities);

   void incrementWild(CardEntry card, Map<String, int> qualities)
    => expansions['WILD']
      !.rarities[card.rarity]
      !.increment(card.normalCollectible, card.goldenCollectible, qualities);

  Summary();
  Summary.fromJson(Map<String, dynamic> json) {
    expansions.clear(); // Clear existing data before populating from JSON
    json.forEach((key, value) {
      expansions[key] = Expansion.fromJson(value);
    });
  }

  Map<String, dynamic> toJson() {
    return expansions.map((key, value) => MapEntry(key, value.toJson()));
  }
}

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
    rarities.clear(); // Ensure rarities are cleared before loading from JSON
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










void subtractUncollectibleSignature(Summary summary){
  var toSubtracts = {
    //always check if golden copy of card is collectible!
    "ISLAND_VACATION.COMMON": 4,
    "ISLAND_VACATION.RARE": 2,
    "ISLAND_VACATION.EPIC": 2,

    "WHIZBANGS_WORKSHOP.COMMON": 4,
    "WHIZBANGS_WORKSHOP.RARE": 0,
    "WHIZBANGS_WORKSHOP.EPIC": 4,

    "WILD_WEST.COMMON": 2,
    "WILD_WEST.RARE": 2,
    "WILD_WEST.EPIC": 4,

    "TITANS.COMMON": 4,
    "TITANS.RARE": 4,
    "TITANS.EPIC": 2,

    "BATTLE_OF_THE_BANDS.COMMON": 4,
  };

  for (var subtraction in toSubtracts.entries) {
    var expansion = subtraction.key.split('.')[0];
    var rarity = subtraction.key.split('.')[1];
    var toSubtract = subtraction.value;

    var oldValue = summary.expansions[expansion]!.rarities[rarity]!.qualities['signature'];
    summary.expansions[expansion]!.rarities[rarity]!.qualities['signature'] = oldValue! - toSubtract;
  }
}

void subtractUncollectibleInWild(Summary summary){
  var toSubtracts = {
    "COMMON.signature": 2,
    "LEGENDARY.regular": 5,
    "LEGENDARY.golden": 1,
  };

  for (var subtraction in toSubtracts.entries) {
    var expansion = 'WILD';
    var rarity = subtraction.key.split('.')[0];
    var quality = subtraction.key.split('.')[1];
    var toSubtract = subtraction.value;

    var oldValue = summary.expansions[expansion]!.rarities[rarity]!.qualities[quality];
    summary.expansions[expansion]!.rarities[rarity]!.qualities[quality] = oldValue! - toSubtract;
  }
}