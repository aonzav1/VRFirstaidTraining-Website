import 'package:flutter/material.dart';

class AppData {
  const AppData._();

  static String imageURL = "http://localhost:13000/";

  static List<String> difficultyLevel = <String>[
    'Very easy',
    'Easy',
    'Normal',
    'Hard',
    'Very hard'
  ];

  static List<String> itemList = <String>[
    'water_bottle',
    'betadine',
    'ice_gel',
    'hot_gel',
    'cotton',
    'cotton_plier',
    'wooden_plate',
    'key',
    'inhaler',
    'bandage',
    'gauze',
    'phone',
  ];

  static List<int> counter = <int>[-1, 0, 1];

  static List<String> injuries = <String>[
    'bruise',
    'abrasion',
    'cutwound',
    'fracture',
    'burn',
    'scorpion stings',
    'centipede bites',
    'bee stings',
    'snake bites',
    'faint',
    'convulsion',
    'no breath',
  ];

  static List<String> level = <String>[
    'Low',
    'Medium',
    'High',
  ];

  static List<String> healthState = <String>[
    'Very weak',
    'Weak',
    'Normal',
    'Good',
  ];

  static List<String> location = <String>[
    '1',
    '2',
    '3',
    '4',
    '5',
  ];

  static List<String> age = <String>[
    'Kid',
    'Adult',
    'Old',
  ];
  static List<String> kidImagePaths = <String>[
    "assets/images/npc_1.jpg",
    "assets/images/npc_2.jpg",
  ];

  static List<String> oldImagePaths = <String>[
    "assets/images/npc_1.jpg",
    "assets/images/npc_2.jpg",
  ];

  static List<String> adultImagePaths = <String>[
    "assets/images/npc_1.jpg",
    "assets/images/npc_2.jpg",
    "assets/images/npc_3.jpg",
    "assets/images/npc_4.jpg",
    "assets/images/npc_5.jpg",
  ];

  static Map<String, List<String>> availableMaps = {
    "Room": ["assets/images/room_map.jpg", "assets/images/room_preview.jpg"],
    "Farm": ["assets/images/farm_map.jpg", "assets/images/farm_preview.jpg"],
    "City": ["assets/images/city_map.jpg", "assets/images/city_preview.jpg"],
  };

  static const dummyText =
      """Lorem Ipsum is simply dummy text of the printing and typesetting
       industry. Lorem Ipsum has been the industry's standard dummy text ever
        since the 1500s, when an unknown printer took a galley of type and
         scrambled it to make a type specimen book. It has survived not only 
         five centuries, but also the leap into electronic typesetting,
          remaining essentially unchanged. It was popularised in the 1960s with
           the release of Letraset sheets containing Lorem Ipsum passages,
            and more recently with desktop publishing software like Aldus
             PageMaker including versions of Lorem Ipsum.""";
}
