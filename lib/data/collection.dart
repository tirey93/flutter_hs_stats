import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';

Future<CollectionData> fetchCollection() async {
  final response = await http
      .get(Uri.parse(
        'https://hsreplay.net/api/v1/collection/?region=2&account_lo=145926188&type=CONSTRUCTED'),
        headers: {
          "cookie": "sessionid=349urrtf4suoy4g5kfds8sqbpf8t4ndn", 
        });

  if (response.statusCode == 200) {
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    return CollectionData.fromJson(json);
  } else {
    throw Exception('Failed to load album');
  }
}

class CollectionData {
  final List<CollectionEntry> collection;

  CollectionData({required this.collection});

  factory CollectionData.fromJson(Map<String, dynamic> json) {
    List<CollectionEntry> parsedCollection = [];

    json['collection'].forEach((key, value) {
      if (value is List) {
        var entry = CollectionEntry(cardId: key, values: value.cast<int>());
        if(entry.hasValue)
          parsedCollection.add(CollectionEntry(cardId: key, values: value.cast<int>()));
      }
    });

    return CollectionData(collection: parsedCollection);
  }
}

class CollectionEntry{
  final String cardId;
  Map<String, int> qualities = {};
  bool hasValue = false;

  CollectionEntry({required this.cardId, required List<int> values}){
    hasValue = values.sum > 0;
    if(values.length == 4){
      qualities = {
        "regular": values[0],
        "golden": values[1],
        "diamond": values[2],
        "signature": values[3],
      };
    }
  }
}