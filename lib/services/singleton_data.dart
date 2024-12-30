import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/kanban_board.dart';
import 'git_services.dart';

class SingletonData {
  // Private constructor
  SingletonData._privateConstructor();

  // The single instance of the class
  static final SingletonData _instance = SingletonData._privateConstructor();

  // Factory constructor to return the same instance each time it's called
  factory SingletonData() {
    return _instance;
  }

  // Data fields
  late String username;
  late String repo;
  late String email;
  late String version;
  late String cm2git;
  Color kSecondaryColor = Colors.white24;
  Color kBackgroundColor = Colors.black87;
  Color kShadowColor = Colors.white54;
  Color kPrimaryColor = Colors.deepPurple;
  bool kDebugMode = false;
  late KanbanBoard kanbanBoard;
  // Holds the current local all-in-one JSON structure
  Map<String, dynamic> allInOneJson = {};

  // --- Methods for Task 1 ---

  // Callback for setState
  VoidCallback? kanbanCardDialogSetState;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  /// Register a callback for setState
  void registerSetStateCallback(VoidCallback callback) {
    kanbanCardDialogSetState = callback;
  }
// Callback for setState
  VoidCallback? kanbanViewSetState;

  late GitHubService gitHubService;


  /// Register a callback for setState
  void registerkanbanViewSetState(VoidCallback callback) {
    kanbanViewSetState = callback;
  }

  // Save indicator
  bool isSaveNeeded = false;

  // Methods to manage save state
  void markSaveNeeded() {
    isSaveNeeded = true;
    kanbanCardDialogSetState?.call(); // Trigger setState in KanbanCardDialog
  }

  void clearSaveNeeded() {
    isSaveNeeded = false;
    kanbanCardDialogSetState?.call(); // Trigger setState in KanbanCardDialog
  }

  /// Splits all-in-one JSON into modular files
  Map<String, String> splitAllInOneJson() {
    // Ensure that allInOneJson is populated
    if (allInOneJson.isEmpty) {
      throw Exception("No data available in all-in-one JSON.");
    }

    // Extract board structure
    Map<String, dynamic> board = {
      "name": allInOneJson["name"],
      "columns": allInOneJson["columns"].map((column) {
        return {
          "id": column["id"],
          "name": column["name"],
          "cards": column["cards"].map((card) => card["id"]).toList(),
          "maxCards": column["maxCards"],
        };
      }).toList(),
    };

    // Serialize board.json
    String boardJson = jsonEncode(board);

    // Extract individual card files
    List<Map<String, dynamic>> columns = List<Map<String, dynamic>>.from(allInOneJson["columns"]);
    Map<String, String> cardFiles = {};
    for (var column in columns) {
      for (var card in column["cards"]) {
        String cardId = card["id"].toString();
        cardFiles[cardId] = jsonEncode(card);
      }
    }

    // Return the modular files as a map
    return {
      "board.json": boardJson,
      ...cardFiles,
    };
  }

  /// Reconstructs all-in-one JSON from modular files
  void reconstructAllInOneJson(Map<String, String> modularFiles) {
    // Parse board.json
    if (!modularFiles.containsKey("board.json")) {
      throw Exception("Board JSON file is missing.");
    }

    Map<String, dynamic> board = jsonDecode(modularFiles["board.json"]!);

    // Parse individual cards and assign them to their respective columns
    List<Map<String, dynamic>> columns = List<Map<String, dynamic>>.from(board["columns"]);
    for (var column in columns) {
      List<dynamic> cardIds = List<dynamic>.from(column["cards"]);
      List<Map<String, dynamic>> cards = [];
      for (var cardId in cardIds) {
        if (!modularFiles.containsKey(cardId.toString())) {
          throw Exception("Card JSON file for ID $cardId is missing.");
        }
        cards.add(jsonDecode(modularFiles[cardId.toString()]!));
      }
      column["cards"] = cards;
    }

    // Reconstruct the all-in-one JSON
    allInOneJson = {
      "name": board["name"],
      "columns": columns,
    };
  }
}

// Example Usage

/*
void main() {
  // Access the singleton instance
  SingletonData data = SingletonData();

  // Populate with mock all-in-one JSON
  data.allInOneJson = {
    "name": "Master Kanban",
    "columns": [
      {
        "id": 1,
        "name": "Product Backlog",
        "cards": [
          {
            "id": 123,
            "title": "Sample Task",
            "description": "This is a sample task",
            "status": "Backlog",
          }
        ],
        "maxCards": 20
      }
    ]
  };

  // Split the JSON into modular files
  Map<String, String> modularFiles = data.splitAllInOneJson();
  print("Modular Files:");
  print(modularFiles);

  // Reconstruct the all-in-one JSON
  data.reconstructAllInOneJson(modularFiles);
  print("Reconstructed All-In-One JSON:");
  print(data.allInOneJson);
}
*/

//example usage

SingletonData setSingles() {
  // Access the singleton instance
  SingletonData data = SingletonData();
  // Set data
  data.repo = 'cm2git';
  data.username = 'jrheisler';
  data.email = 'john.doe@example.com';
  data.cm2git = 'iru]-24l;sfLJKPJasd2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dhjksakilkj809ja09sL';

  return data;
}

String retrieveString(String embedded) {
  // Extract the 40-character string from the middle
  int start = (embedded.length - 40) ~/ 2;
  return embedded.substring(start, start + 40);
}

