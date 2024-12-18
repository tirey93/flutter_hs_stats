import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hs_stats/data/card.dart';
import 'package:hs_stats/data/collection.dart';
import 'package:hs_stats/data/expansion.dart';
import 'package:hs_stats/config.dart' as cfg;

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
        var sumOfRegularInPosses = entry.qualities.entries
          .where((x) => x.key == "regular")
          .map((x) => x.value)
          .sum;
        
        if(card.set == "BATTLE_OF_THE_BANDS" && card.rarity == "COMMON" && sumOfRegularInPosses > 0){
          int a = 5;
        }

        summary.incrementStandard(card, entry.qualities);
      }
      else{
        var sumOfRegularInPosses = entry.qualities.entries
          .where((x) => x.key == "regular")
          .map((x) => x.value)
          .sum;
        if(card.rarity == "LEGENDARY" && sumOfRegularInPosses > 0 && card.normalCollectible){
          // print(card.name);
        }

        summary.incrementWild(card, entry.qualities);
      }
    }
  }

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
  final Map<String, Expansion> expansions = cfg.Config.expansions;

  void incrementStandard(CardEntry card, Map<String, int> qualities)
  => expansions[card.set]
    !.rarities[card.rarity]
    !.increment(card, qualities);

  void incrementWild(CardEntry card, Map<String, int> qualities)
  => expansions['WILD']
    !.rarities[card.rarity]
    !.increment(card, qualities);

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