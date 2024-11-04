import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserDataModel with ChangeNotifier{
  final String name;
  final List<dynamic> savedRecipes;
  final List<dynamic> recentRecipes;
  final List<dynamic> children;
  final bool custom;


  UserDataModel({
    required this.name,
    required this.savedRecipes,
    required this.recentRecipes,
    required this.children,
    required this.custom,
  });

  factory UserDataModel.fromMap(Map<String, dynamic> data) {
    return UserDataModel(
      name: data['name'] ?? '',
      savedRecipes: List<String>.from(data['savedRecipes'] ?? []),
      recentRecipes: List<String>.from(data['recent'] ?? []),
      children: List.from(data['children'] ?? ['adults']),
      custom: data['custom'] ?? false,
    );
  }
  Future<void> addChild(Map<String, dynamic> newChildData, userId) async {
    // Reference to the user's children collection or document
    final userRef = FirebaseFirestore.instance.collection('Users').doc(userId); // Replace userId as needed

    // Update the children data in Firestore
    await userRef.update({
      'children': FieldValue.arrayUnion([newChildData]),
    });

    // Update the local list and notify listeners
    children.add(newChildData);
    notifyListeners();
  }

}


