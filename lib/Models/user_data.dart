import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'user_data.g.dart';

@HiveType(typeId: 0) // Assign a unique typeId
class UserDataModel with ChangeNotifier{
  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<dynamic> savedRecipes;

  @HiveField(2)
  final List<dynamic> recentRecipes;

  @HiveField(3)
  final List<dynamic> children;

  @HiveField(4)
  bool custom;

  @HiveField(5)
  int swapped;

  @HiveField(6)
  final DateTime lastUpdated;

  UserDataModel({
    required this.name,
    required this.savedRecipes,
    required this.recentRecipes,
    required this.children,
    required this.custom,
    required this.swapped,
    required this.lastUpdated
  });

  UserDataModel copyWith({
    String? name,
    List<dynamic>? savedRecipes,
    List<dynamic>? recentRecipes,
    List<dynamic>? children,
    bool? custom,
    int? swapped,
    lastUpdated,
  }) {
    return UserDataModel(
      name: name ?? this.name,
      savedRecipes: savedRecipes ?? this.savedRecipes,
      recentRecipes: recentRecipes ?? this.recentRecipes,
      children: children ?? this.children,
      custom: custom ?? this.custom,
      swapped: swapped ?? this.swapped,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory UserDataModel.fromMap(Map<String, dynamic> data, bool recent) {

    final lastUpdated = data['lastUpdated'] != null
        ? (data['lastUpdated'] is Timestamp
        ? (data['lastUpdated'] as Timestamp).toDate() // Convert Timestamp to DateTime
        : DateTime.parse(data['lastUpdated'])) // Fallback for String (if needed)
        : DateTime.now();

    print('reached');

    return UserDataModel(
      name: data['name'] ?? '',
      savedRecipes: List<String>.from(data['savedRecipes'] ?? []),
      recentRecipes: List<String>.from(data['recentRecipes'] ?? []),
      children: List.from(data['children'] ?? ['adults']),
      custom: data['custom'] ?? false,
      swapped: data['swapped'] ?? 0,
      lastUpdated: lastUpdated ?? DateTime.now(), // Default to current time if not available
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'savedRecipes': savedRecipes,
      'recentRecipes': recentRecipes,
      'children': children,
      'custom': custom,
      'swapped': swapped,
      'lastUpdated': lastUpdated.toIso8601String()
    };
  }

  void updateUserData({
    required String uid,
    required String? recipeId,
    bool isSaved = false,
    bool add = true, // Add or remove for saved recipes
    bool isRecent = false,
  }) {
    final userBox = Hive.box('userData');
    final cachedData = userBox.get('userInfo');

    if (cachedData != null) {
      final userData = UserDataModel.fromMap(Map<String, dynamic>.from(cachedData), false);
      List updatedSavedRecipes = cachedData['savedRecipes'];
      List updatedRecentRecipes = cachedData['recentRecipes'];

      print(cachedData['recentRecipes'].toString());

      if (isSaved) {
        if (add) {
          if (!updatedSavedRecipes.contains(recipeId)) {
            updatedSavedRecipes.add(recipeId!);
          }
        } else {
          updatedSavedRecipes.remove(recipeId);
        }
      }

      if (isRecent) {
        if (updatedRecentRecipes.contains(recipeId)) {
          // Remove the recipe from its previous position
          updatedRecentRecipes.remove(recipeId);
        }
        // Add the recipe to the beginning of the list
        updatedRecentRecipes.insert(0, recipeId!);

        // Trim the list to ensure it doesn’t exceed the limit (e.g., 10 items)
        if (updatedRecentRecipes.length > 10) {
          updatedRecentRecipes.removeLast();
        }
      }

      final updatedUser = userData.copyWith(
        savedRecipes: updatedSavedRecipes,
        recentRecipes: updatedRecentRecipes,
        lastUpdated: DateTime.now()
      );

      userBox.put('userInfo', updatedUser.toMap());
      print('**********/*///////*/*/*/************');
      print(updatedUser.recentRecipes);
      print('**********/**/*/*/*/*/*/*/***********');
      notifyListeners(); // Notify listeners of changes
    }
  }

}

