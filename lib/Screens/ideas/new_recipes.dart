import 'package:flutter/material.dart';
import 'package:meal/DataBase/fetch_db.dart';
import 'package:meal/DataBase/storage.dart';
import 'package:meal/Models/decoration.dart';
import 'package:meal/Models/meal_card.dart';
import 'package:provider/provider.dart';

import '../../Models/user_data.dart';

class NewRecipes extends StatefulWidget {
  String uid;
  NewRecipes({required this.uid});

  @override
  State<NewRecipes> createState() => _NewRecipesState();
}

class _NewRecipesState extends State<NewRecipes> {

  Future<List<Map<String, dynamic>>> _loadRecipes() async {
    var recipes;
    try {
      final fetchedRecipes = await Fetch(uid: widget.uid).newRecipes();
      return fetchedRecipes;
    } catch (e) {
      print('Error fetching recipes: $e');
    }
    return recipes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading contributions"));
          }
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("No contributions yet"));
          }

          final recipes = snapshot.data!;

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final meal = recipes[recipes.length - 1 - index];

              return MealCard(meal: meal, home: false, index: index);
            },
          );
        }
    );
  }
}
