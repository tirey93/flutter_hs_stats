import 'dart:convert';
import 'package:http/http.dart' as http;

Future<CardsData> fetchCards() async {
  final response = await http
      .get(Uri.parse('https://api.hearthstonejson.com/v1/latest/enUS/cards.json'));

  if (response.statusCode == 200) {
    var json = jsonDecode(response.body) as List<dynamic>;
    return CardsData.fromJson(json);
  } else {
    throw Exception('Failed to load album');
  }
}

class CardsData {
  final Map<String, CardEntry> cards;

  CardsData({required this.cards});

  factory CardsData.fromJson(List<dynamic> json) {
    Map<String, CardEntry> parsedCards = {};

    for (var value in json) {
      if (value['dbfId'] != null && value['name'] != null && value['set'] != null && value['rarity'] != null && value['rarity'] != 'FREE'){
        var normalCollectible = value['howToEarn'] == null;
        var goldenCollectible = value['howToEarnGolden'] == null;
        var entry = CardEntry(
          dbfId: value['dbfId'].toString(),
          name: value['name'],
          set: value['set'],
          rarity: value['rarity'],
          normalCollectible: normalCollectible,
          goldenCollectible: goldenCollectible
        );
        parsedCards[entry.dbfId] = entry;
      }
    }

    return CardsData(cards: parsedCards);
  }
}

class CardEntry{
  final String dbfId;
  final String name;
  final String set;
  final String rarity;
  final bool normalCollectible;
  final bool goldenCollectible;

  CardEntry({required this.dbfId, required this.name, required this.set, required this.rarity, required this.normalCollectible, required this.goldenCollectible});
}