import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meal/Screens/recipes/recipe_list.dart';
import 'package:provider/provider.dart';
import '../../DataBase/fetch_db.dart';
import '../../DataBase/state_mgt.dart';
import '../../DataBase/storage.dart';
import '../../Models/connection.dart';
import '../../Models/meal_card.dart';
import '../../Models/user_data.dart';
import '../../Models/user_id.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  final ValueNotifier<double> _opacityNotifier = ValueNotifier(0.0);
  final List<Map<String, dynamic>> categories = [
    {'name': 'All Recipes', 'icon': Icons.restaurant_menu, 'gradient': [Colors.blue[50]!, Colors.blue[100]!]},
    {'name': 'Breakfast', 'icon': Icons.breakfast_dining, 'gradient': [Colors.orange[50]!, Colors.orange[100]!]},
    {'name': 'Main Dish', 'icon': Icons.dinner_dining, 'gradient': [Colors.red[50]!, Colors.red[100]!]},
    {'name': 'Dessert', 'icon': Icons.cake, 'gradient': [Colors.pink[50]!, Colors.pink[100]!]},
    {'name': 'Snacks', 'icon': Icons.cookie, 'gradient': [Colors.green[50]!, Colors.green[100]!]},
    {'name': 'Drinks', 'icon': Icons.local_drink, 'gradient': [Colors.purple[50]!, Colors.purple[100]!]},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController()
      ..addListener(() {
        double offset = _scrollController.offset;
        double maxScroll = _scrollController.position.maxScrollExtent;
        double newOpacity = (offset / maxScroll).clamp(0.0, 1.0);
        _opacityNotifier.value = newOpacity;
      });
  }

  Future<List<Map<String, dynamic>>> getRecipeDetails(UserDataModel? userData, bool isRecentlyViewed) async {
    if (userData == null) {
      return [];
    }

    final recipeIds = isRecentlyViewed ? userData.recentRecipes : userData.savedRecipes;

    if (recipeIds.isEmpty) {
      return [];
    }

    // Fetch additional recipe details from Hive
    final recipes = await getSavedRecipesFromHive(recipeIds);
    return recipes;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _opacityNotifier.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserID>(context);
    final userData = context.watch<UserDataModel?>();

    if (userData == null) {
      return Center(child: Text('No user data available'));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            floating: true,
            pinned: true,
            expandedHeight: MediaQuery.sizeOf(context).width * 2 / 3 + 90,
            toolbarHeight: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: AnimatedBuilder(
                animation: _opacityNotifier,
                builder: (context, child) {
                  double opacity = _opacityNotifier.value;
                  return Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(top: 50),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              child: const Text(
                                'Recipe Collection',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Expanded(child: _buildCategories()),
                            const SizedBox(height: 60),
                          ],
                        ),
                        IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAE4DD).withOpacity(opacity),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: AnimatedBuilder(
                animation: _opacityNotifier,
                builder: (context, child) {
                  double opacity = _opacityNotifier.value;
                  return Stack(
                    children: [
                      Container(
                        color: Colors.white.withOpacity(1 - opacity),
                        height: 50,
                        width: MediaQuery.sizeOf(context).width,
                      ),
                      Container(
                        color: const Color(0xFFFAEFEB).withOpacity(opacity),
                        child: TabBar(
                          controller: _tabController,
                          labelColor: const Color(0xDBF32607),
                          indicatorWeight: 3,
                          tabs: const [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history, size: 20),
                                  SizedBox(width: 8),
                                  Text('Recently Viewed'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.bookmark, size: 20),
                                  SizedBox(width: 8),
                                  Text('Saved Recipes'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildRecipeList(true),
            _buildRecipeList(false),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) => _buildCategoryCard(index),
    );
  }

  Widget _buildCategoryCard(int index) {
    final category = categories[index];
    final user = Provider.of<UserID>(context);
    final userData = Provider.of<UserDataModel?>(context);
    Fetch fetch = Fetch(uid: user.uid);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          if (index == 0) {
            List<Map<String, dynamic>> recipes = await fetch.getAllRecipes();
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => RecipeList(recipes: recipes, userData: userData, swap: false, index: null, meal: {}, day: null, name: [],
                  child: null,)));
          } else {
            List<Map<String, dynamic>> recipes = await fetch.getRecipesByType(index);
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => RecipeList(recipes: recipes, userData: userData, swap: false, index: null, meal: {}, day: null, name: [],
                  child: null,)));
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey.shade100, Colors.grey.shade200],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category['icon'],
                size: 32,
                color: Color(0xDBF32607),
              ),
              const SizedBox(height: 8),
              Text(
                category['name'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeList(bool isRecentlyViewed) {
    final userData = context.watch<UserDataModel?>();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getRecipeDetails(userData, isRecentlyViewed),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[700]!),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading recipes'));
        }

        final recipes = snapshot.data;
        if (recipes == null || recipes.isEmpty) {
          return Center(
            child: Text(
              isRecentlyViewed
                  ? 'No recently viewed recipes'
                  : 'No saved recipes yet',
            ),
          );
        }

        return _buildMeal(recipes);
      },
    );
  }

  Widget _buildMeal(List<Map<String, dynamic>> recipes) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: MealCard(
            meal: recipe,
            home: false,
            index: index,
          ),
        );
      },
    );
  }
}
