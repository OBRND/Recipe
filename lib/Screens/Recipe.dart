import 'package:flutter/material.dart';
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
                        const TabBar(
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.black45,
                          indicatorColor: Color(0xD7DF1313),
                          tabs: [
                            Tab(text: 'Recently Viewed'),
                            Tab(text: 'Saved Recipes'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // First tab: Saved Recipes content.
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: 4,
                                // Replace with the number of saved recipes.
                                itemBuilder: (context, index) =>
                                    ListTile(
                                      title: Text(
                                          'Saved Recipe $index'), // Replace with actual saved recipe data.
                                    ),
                              ),
                              // Second tab: Recently Viewed Recipes content.
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: 4,
                                itemBuilder: (context, index) =>
                                    ListTile(
                                      title: Text(
                                          'Recently Viewed $index'),
                                    ),
                              ),
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
