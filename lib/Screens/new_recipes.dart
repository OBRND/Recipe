import 'package:flutter/material.dart';
import 'package:meal/DataBase/fetch_db.dart';
import 'package:meal/DataBase/storage.dart';
import 'package:meal/Models/decoration.dart';
import 'package:meal/Models/meal_card.dart';
import 'package:provider/provider.dart';

import '../Models/user_data.dart';

class NewRecipes extends StatefulWidget {
  String uid;
  NewRecipes({required this.uid});

  @override
  State<NewRecipes> createState() => _NewRecipesState();
}

class _NewRecipesState extends State<NewRecipes> {
  List<Map<String, dynamic>> recipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    try {
      final fetchedRecipes = await Fetch(uid: widget.uid).newRecipes();
      setState(() {
        recipes = fetchedRecipes;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching recipes: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserDataModel?>(context);
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (recipes.isEmpty) {
      return const Center(child: Text("No new recipes available."));
    }

    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final meal = recipes[recipes.length - 1 - index];

        return MealCard(meal: meal, home: false, index: index);
      },
    );
  }
}
