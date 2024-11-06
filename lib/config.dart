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
  static Set<String> get uncollectibleSignatures => {
    //SPACE
    "Red Giant",
    
    //ISLAND_VACATION
    "Hydration Station",
    "Power Spike",
    "Tidepool Pupil",
    "Mixologist",

    //WHIZBANGS_WORKSHOP
    "Rambunctious Stuffy",
    "Toyrannosaurus",
    "Watercolor Artist",
    "Corridor Sleeper",

    //WILD_WEST
    "Pile of Bones",
    "Wishing Well",
    "Walking Mountain",
    "Howdyfin",
    "Kobold Miner",
    "High Noon Duelist",

    //TITANS
    "Astral Serpent",
    "Imprisoned Horror",
    "Minotauren",
    "Ravenous Kraken",
    "Angry Helhound",

    //BATTLE_OF_THE_BANDS
    "Void Virtuoso",
    "Cowbell Soloist",

    //WILD
    "Deathlord",
    "Northshire Cleric",
  };
  static Set<String> get uncollectibleRegulars => {
    //LEGENDARIES
    "Altruis the Outcast",
    "Nethrandamus",
    "Silas Darkmoon",
    "Flightmaster Dungar",
    "Prince Renathal",
  };
  static Set<String> get uncollectibleGoldens => {
    //LEGENDARIES
    "SN1P-SN4P",
  };
}