import 'dart:convert';
import 'package:hs_stats/data/expansion.dart';
import 'package:http/http.dart' as http;

class Config {
  static late String _lastRotationDate;
  static late Map<String, Expansion> _expansions;
  static late Set<String> _uncollectibleSignatures;
  static late Set<String> _uncollectibleRegulars;
  static late Set<String> _uncollectibleGoldens;

  static Future<void> init() async {
    final response = await http.get(Uri.parse('https://raw.githubusercontent.com/tirey93/flutter_hs_stats/refs/heads/main/sources/config.json'));
  
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

      _lastRotationDate = jsonData['lastRotationDate'];
      _expansions = {};
      (jsonData['expansions'] as Map<String, dynamic>).forEach((key, value) {
        _expansions[key] = Expansion(value['fullName'], value['yearName'], value['shortName'], value['releaseYear'], value['releaseMonth']);
      });

      _uncollectibleSignatures = Set<String>.from(jsonData['uncollectibleSignatures'] as List<dynamic>);
      _uncollectibleRegulars = Set<String>.from(jsonData['uncollectibleRegulars'] as List<dynamic>);
      _uncollectibleGoldens = Set<String>.from(jsonData['uncollectibleGoldens'] as List<dynamic>);
    } else {
      throw Exception('Failed to load JSON: ${response.statusCode}');
    }
  }

  static String get lastRotationDate => _lastRotationDate;
  static Map<String, Expansion> get expansions => _expansions;
  static Set<String> get uncollectibleSignatures => _uncollectibleSignatures;
  static Set<String> get uncollectibleRegulars => _uncollectibleRegulars;
  static Set<String> get uncollectibleGoldens => _uncollectibleGoldens;
}