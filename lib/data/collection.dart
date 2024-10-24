import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

Future<CollectionData> fetchCollection(Auth auth) async {
  final response = await http
      .get(Uri.parse(
        'https://hsreplay.net/api/v1/collection/?region=2&account_lo=${auth.login}&type=CONSTRUCTED'),
        headers: {
          "cookie": "sessionid=${auth.session}", 
        });
  if (response.statusCode == 200) {
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    return CollectionData.fromJson(json);
  } else {
    throw Exception('Failed to load collection');
  }
}

class CollectionData {
  final List<CollectionEntry> collection;
  final AdditionalInfo additionalInfo;

  CollectionData({required this.collection, required this.additionalInfo});

  factory CollectionData.fromJson(Map<String, dynamic> json) {
    List<CollectionEntry> parsedCollection = [];
    
    json['collection'].forEach((key, value) {
      if (value is List) {
        var entry = CollectionEntry(cardId: key, values: value.cast<int>());
        if(entry.hasValue)
          parsedCollection.add(CollectionEntry(cardId: key, values: value.cast<int>()));
      }
    });

    DateFormat format = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
    var dateTime = format.parse(json['lastModified']).add(Duration(hours: 2));
    AdditionalInfo additionalInfo = AdditionalInfo(rares: json['dust'] ~/ 20, lastModified: dateTime);
    return CollectionData(collection: parsedCollection, additionalInfo: additionalInfo);
  }
}

class AdditionalInfo {
  final int rares;
  final DateTime lastModified;

  AdditionalInfo({required this.rares, required this.lastModified});
  AdditionalInfo.fromJson(Map<String, dynamic> json)
      : rares = json['rares'],
        lastModified = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(json['lastModified']);

  Map<String, dynamic> toJson() => {
        'rares': rares,
        'lastModified':  DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(lastModified),
      };
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

class Auth {
  String login = "";
  String session = "";

  Auth({this.login = "", this.session = ""});

  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'session': session,
    };
  }

  static Auth fromJson(Map<String, dynamic> json) {
    return Auth(
      login: json['login'] as String,
      session: json['session'] as String,
    );
  }
}