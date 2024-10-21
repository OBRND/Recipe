import 'package:flutter/material.dart';

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
                        TabBar(
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
    return GridView.builder(
      shrinkWrap: true,
      itemCount: 5,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3),
      itemBuilder: (context, index) =>
          GridTile(
            child: Card(
              child: InkWell(
                onTap: () {

                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.black12,
                      ),
                    ),
                    Container(
                        color: Color(0xE4C10606),
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
