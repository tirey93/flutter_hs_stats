import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hs_stats/data/card.dart';
import 'package:hs_stats/data/collection.dart';
import 'package:hs_stats/data/expansion.dart';

Future<Summary> fetchSummary(Auth auth) async {
  var collectionFuture = fetchCollection(auth);
  var cardsFuture = fetchCards();
  late CollectionData collection;
  late CardsData cards;

  await Future.wait([
    collectionFuture.then((value) => collection = value),
    cardsFuture.then((value) => cards = value)
  ]);

  var summary = Summary(collection.additionalInfo);
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
  AdditionalInfo? additionalInfo;
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

  Summary(this.additionalInfo);
  Summary.fromJson(Map<String, dynamic> json) {
    expansions.clear();
    json.forEach((key, value) {
      if (key == 'additionalInfo') {
        additionalInfo = AdditionalInfo.fromJson(value);
      } else {
        expansions[key] = Expansion.fromJson(value);
      }
    });
  }
  Map<String, dynamic> toJson() {
    final map = expansions.map((key, value) => MapEntry(key, value.toJson()));
    if (additionalInfo != null) {
      map['additionalInfo'] = additionalInfo!.toJson();
    }
    return map;
  }
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