import 'package:flutter/material.dart';
import 'package:meal/Models/user_id.dart';
import 'package:meal/Screens/recipe_details.dart';
import 'package:meal/Screens/recipe_list.dart';
import 'package:provider/provider.dart';
import '../DataBase/fetch_db.dart';
import '../Models/user_data.dart';

class Recipes extends StatefulWidget {
  const Recipes({super.key});

  @override
  State<Recipes> createState() => _RecipesState();
}

class _RecipesState extends State<Recipes> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 2, // Two tabs: All Recipes and Ideas
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: const TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black45,
              indicatorColor: Color(0xFFFF3C00),
              tabs: [
                Tab(text: "Ideas",
                height: 30,),
                Tab(text: "All Recipes",
                height: 30),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            AllRecipesTab(), // New widget for "All Recipes"
            IdeasTab(),      // New widget for "Ideas"
          ],
        ),
      ),
    );
  }
}

class AllRecipesTab extends StatelessWidget {
  const AllRecipesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserID>(context);
    final userDataa = Provider.of<UserDataModel?>(context);

    return Column(
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
                      onTap: (i) {},
                      tabs: const [
                        Tab(text: 'Recently Viewed'),
                        Tab(text: 'Saved Recipes'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          commonFuture(true, context),
                          commonFuture(false, context)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]
    );
  }

  Widget commonFuture(bool selector, context){

    final user = Provider.of<UserID>(context);
    final userDataa = Provider.of<UserDataModel?>(context);

    return  FutureBuilder(
      future: Fetch(uid: user.uid).getSavedRecipes(selector ? userDataa!.recentRecipes : userDataa!.savedRecipes), // Fetch saved recipes.
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
                      builder: (BuildContext context) => Consumer<UserDataModel?>(
                        builder: (context, user, child) {
                          return RecipeDetailsPage(
                            recipeID: recipe['id'],
                            imageURL: 'https://img.jamieoliver.com/jamieoliver/recipe-database/oldImages/large/576_1_1438868377.jpg?tr=w-800,h-1066',
                            foodName: recipe['name'],
                            ingredients: recipe['ingredients'],
                            selected: userDataa.savedRecipes.contains(recipe['id']) ? true : false,
                          );
                        },
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
    final user = Provider.of<UserID>(context);
    final Userdata = Provider.of<UserDataModel?>(context);

    Fetch User = Fetch(uid: user.uid);
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
                        builder: (context) => RecipeList(recipes: recipes, userData: Userdata, swap: false, index: null, meal: {}, day: null, name: [],
                          child: null,)));
                  } else {
                    List<Map<String, dynamic>> recipes = await User.getRecipesByType(index);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => RecipeList(recipes: recipes, userData: Userdata, swap: false, index: null, meal: {}, day: null, name: [],
                          child: null,)));
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

class IdeasTab extends StatelessWidget {
  const IdeasTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle("Recommended for You"),
          RecommendedSection(),
          const SectionTitle("Community Picks"),
          CommunitySection(),
          const SectionTitle("Explore More"),
          ExploreMoreSection(),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class RecommendedSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace this placeholder with the logic to display recommended recipes.
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Example count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: Container(width: 150, color: Colors.grey[300]),
          );
        },
      ),
    );
  }
}

class CommunitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace this placeholder with the logic to display trending recipes.
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Example count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: Container(width: 150, color: Colors.grey[300]),
          );
        },
      ),
    );
  }
}

class ExploreMoreSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace this placeholder with the logic to display additional content.
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text("Explore more content coming soon..."),
    );
  }
}
