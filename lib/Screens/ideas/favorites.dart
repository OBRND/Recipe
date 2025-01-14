import 'package:flutter/material.dart';
import 'package:meal/DataBase/fetch_db.dart';
import 'package:meal/Models/meal_card.dart';

class CommunityFavorites extends StatefulWidget {
  String uid;

  CommunityFavorites({required this.uid});

  @override
  State<CommunityFavorites> createState() => _CommunityFavoritesState();
}

class _CommunityFavoritesState extends State<CommunityFavorites> {
  List<Map<String, dynamic>> favoriteRecipes = [];
  bool isLoading = true;

  Future<List<Map<String, dynamic>>> _loadFavorites() async {
    final Fetch _fetch = Fetch(uid: widget.uid);
    var favs;
    try {
      final favorites = await _fetch.fetchFavorites(10);
      return favorites;
    } catch (e) {
      print('Error fetching favorites: $e');

    }
    return favs;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadFavorites(),
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
            physics: const BouncingScrollPhysics(),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final meal = recipes[index];

              return MealCard(meal: meal, home: false, index: index);
            },
          );
        });
  }
}
