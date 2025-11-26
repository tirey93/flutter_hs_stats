import 'package:hs_stats/data/expansion.dart';

class Config {
  static String get lastRotationDate => "2025-03-25";
  static Map<String, Expansion> get expansions => {
    "EMERALD_DREAM": Expansion("Emerald Dream", "Year of the Raptor", "Emerald", 2025, 3),
    "THE_LOST_CITY": Expansion("The Lost City of Un'Goro", "Year of the Raptor", "Lost", 2025, 7),
    "TIME_TRAVEL": Expansion("Across the Timeways", "Year of the Raptor", "Timeways", 2025, 11),

    "WHIZBANGS_WORKSHOP": Expansion("Whizbang's Workshop", "Year of the Pegasus", "Whizbang", 2024, 3),
    "ISLAND_VACATION": Expansion("Perils in Paradise", "Year of the Pegasus", "Perils", 2024, 7),
    "SPACE": Expansion("Great Dark Beyond", "Year of the Pegasus", "Beyond", 2024, 11),

    "WILD": Expansion("Wild", 'Wild', "Wild", null, null),
  };
  static Set<String> get uncollectibleSignatures => {
    //TIMEWAYS
    "Hourglass Attendant",
    "Paltry Flutterwing",
    "Futuristic Forefather",
    "Azure Queen Sindragosa"

    //EMERALD
    "Ancient of Yore",
    "Hopeful Dryad",
    "Tranquil Treant"

    //SPACE
    "Red Giant",
    "Galactic Crusader",
    "Supernova",
    
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