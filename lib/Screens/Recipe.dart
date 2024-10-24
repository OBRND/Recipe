import 'package:flutter/material.dart';
import 'package:meal/DataBase/Write_DB.dart';
import 'package:meal/Screens/RecipeDetails.dart';
import 'package:meal/Screens/RecipeList.dart';
import 'package:provider/provider.dart';

import '../DataBase/Fetch_DB.dart';

class Recipes extends StatefulWidget {
  const Recipes({super.key});

  @override
  State<Recipes> createState() => _RecipesState();
}

class _RecipesState extends State<Recipes> {
  @override
  Widget build(BuildContext context) {
    final value = Provider.of<String>(context);
    return Scaffold(
        body: Column(
            children: [
              Container(
                child: Categories(context),
              ),
              Expanded(
                child: Container(
                  child: DefaultTabController(
                    length: 2, // Two tabs: Saved Recipes and Recently Viewed
                    child: Column(
                      children: [
                        // Tab selector for switching between saved and recent recipes.
                        TabBar(
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.black45,
                          indicatorColor: Color(0xD7DF1313),
                          onTap: (i) {
                            print(i);
                          },
                          tabs: const [
                            Tab(text: 'Recently Viewed'),
                            Tab(text: 'Saved Recipes'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              commonFuture(value, true),
                              commonFuture(value, false)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]
        )
    );
  }

  Widget commonFuture(String value, bool selector){
    return  FutureBuilder(
      future: Fetch(uid: value).getSavedRecipes(selector), // Fetch saved recipes.
      builder: (context, snapshot) {
        // Show loading indicator while fetching data.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        // Check if there's an error.
        if (snapshot.hasError) {
          return Center(child: Text('Error loading saved recipes.'));
        }
        // Check if data is available.
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final recipe = snapshot.data![snapshot.data!.length - 1 - index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailsPage(
                        recipeID: recipe['id'],
                        imageURL:
                        'https://img.jamieoliver.com/jamieoliver/recipe-database/oldImages/large/576_1_1438868377.jpg?tr=w-800,h-1066',
                        foodName: recipe['name'],
                        ingredients: [
                          Ingredient(
                              name: 'pepper', measurement: '20 oz')
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 100,
                  child: Card(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            image: const DecorationImage(
                              image: NetworkImage(
                                  'https://img.jamieoliver.com/jamieoliver/recipe-database/oldImages/large/576_1_1438868377.jpg?tr=w-800,h-1066'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            recipe['name'],
                            style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
        // Show a message if there are no saved recipes.
        return Center(child: Text('No saved recipes found.'));
      },
    );
  }

  Widget Categories(context) {
    final value = Provider.of<String>(context);
    Fetch User = Fetch(uid: value);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 840),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: 5,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200),
        itemBuilder: (context, index) =>
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  if (index == 4) {
                    List<Map<String, dynamic>> recipes = await User.getAllRecipes();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => RecipeList(recipes: recipes)));
                  } else {
                    List<Map<String, dynamic>> recipes = await User.getRecipesByType(index);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => RecipeList(recipes: recipes)));
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10)),
                            color: Colors.black12
                        ),
                      ),
                    ),
                    Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                          color: Color(0xE4C10606),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(style: TextStyle(color: Colors.white),
                              index == 0 ? 'Breakfast' :
                              index == 1 ? 'Main Dish' :
                              index == 2 ? 'Dessert' :
                              index == 3 ? 'Snacks' :
                              'All'
                          ),
                        )
                    )
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
