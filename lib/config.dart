import 'package:hs_stats/data/expansion.dart';

class Config {
  static String get lastRotationDate => "2024-03-19";
  static Map<String, Expansion> get expansions => {
    "WHIZBANGS_WORKSHOP": Expansion("Whizbang's Workshop", "Year of the Pegasus", "Whizbang", 2024, 3),
    "ISLAND_VACATION": Expansion("Perils in Paradise", "Year of the Pegasus", "Perils", 2024, 7),
    "SPACE": Expansion("Great Dark Beyond", "Year of the Pegasus", "Beyond", 2024, 11),

    "BATTLE_OF_THE_BANDS": Expansion("Festival of Legends", "Year of the Wolf", "Festival", 2023, 4),
    "TITANS": Expansion("Titans", 'Year of the Wolf', "Titans", 2023, 8),
    "WILD_WEST": Expansion("Showdown in the Badlands", "Year of the Wolf", "Badlands", 2023, 11),

    "WILD": Expansion("Wild", 'Wild', "Wild", null, null),
  };
  static Map<String, int> get uncollectibleSignatures => {
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
  static Map<String, int> get uncollectibleInWild => {
    "COMMON.signature": 2,
    "LEGENDARY.regular": 5,
    "LEGENDARY.golden": 1,
  };
}