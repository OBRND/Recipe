import 'package:flutter/material.dart';
import 'package:meal/DataBase/fetch_db.dart';
import 'package:meal/DataBase/storage.dart';

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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (recipes.isEmpty) {
      return const Center(child: Text("No new recipes available."));
    }

    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final meal = recipes[index];

        return Container(
          height: MediaQuery.sizeOf(context).width / 2.8,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: MediaQuery.sizeOf(context).width / 3.2,
                  decoration: BoxDecoration(
                    color: const Color(0xe7f8f3f1),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width / 3,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal['name'],
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Perfect for family dinner',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.star,
                                    size: 16, color: Colors.orange[700]),
                                const SizedBox(width: 4),
                                Text(
                                  '4.8',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.timer_outlined,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  '${meal['cookingTime']} min',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Stack(
                children: [
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.all(0),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width / 2.8,
                      decoration: BoxDecoration(
                        borderRadius:
                        const BorderRadius.all(Radius.circular(12)),
                        image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          image: NetworkImage(meal['imageUrl']),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 25,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(15),
                        topLeft: Radius.circular(12),
                      ),
                      color: Colors.orange.withOpacity(.8),
                    ),
                    child: Center(
                      child: Text(
                        'New',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
