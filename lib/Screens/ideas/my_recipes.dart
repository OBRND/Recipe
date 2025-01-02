import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../DataBase/fetch_db.dart';
import '../../Models/meal_card.dart';

class MyContributionsScreen extends StatefulWidget {
  String uid;

  MyContributionsScreen({required this.uid});

  @override
  State<MyContributionsScreen> createState() => _MyContributionsScreenState();
}

class _MyContributionsScreenState extends State<MyContributionsScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = true;

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadContributions() async {
    final Fetch _fetch = Fetch(uid: widget.uid);
    var contributions;
    try {
       contributions = await _fetch.userContributions();
    } catch (e) {
      print('Error fetching favorites: $e');
    }
    return contributions;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadContributions(),
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
            final recipe = recipes[index];

            return MealCard(meal: recipe, home: false, index: index);
          },
        );
      },
    );
  }
}
