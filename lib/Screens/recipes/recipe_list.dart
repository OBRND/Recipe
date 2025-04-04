import 'dart:isolate';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../../DataBase/fetch_db.dart';
import '../../DataBase/storage.dart';
import '../../DataBase/write_db.dart';
import '../../Models/connection.dart';
import '../../Models/user_data.dart';
import '../../Models/user_id.dart';
import './recipe_details.dart';

class RecipeList extends StatefulWidget {
  List<Map<String, dynamic>> recipes;
  final UserDataModel? userData;
  final bool swap;
  final int? index;
  final int? day;
  final int? child;
  final Map meal;
  final List? name;
  final UserDataModel? userInfo;

  RecipeList({
    super.key,
    required this.recipes,
    required this.swap,
    required this.userData,
    required this.index,
    required this.meal,
    required this.day,
    required this.child,
    required this.name,
    this.userInfo,
  });

  @override
  State<RecipeList> createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  String searchQuery = '';
  String selectedFilter = 'All';
  final List<String> filterOptions = ['All', 'Age Group', 'Gluten-Free', 'Vegan'];
  bool isLoading = true;
  int recipesIndex = 0;
  List<Map<String, dynamic>> weeklyPlan = [];
  bool loadfinished = false;

  @override
  void initState() {
    super.initState();
  }

  Future<List<Map<String, dynamic>>> _fetchRecipesInIsolate(String uid, int index) async {
    return await Fetch(uid: uid).getRecipesByType(index + 1);
  }

  Future<void> _fetchRecipes(String uid, int? index) async {
    if (index == null) return;

    final fetched = !widget.swap ? await Isolate.run(() => _fetchRecipesInIsolate(uid, index))
        : await Fetch(uid: uid).getRecipesByType(index + 1);

    if (mounted) {
      setState(() {
        weeklyPlan = widget.recipes;
        widget.recipes = fetched;
        isLoading = false;
        recipesIndex = index;
        loadfinished = true;
      });
    }
  }

  Future<void> _fetch(String uid) async{
    Fetch fetch = Fetch(uid: uid);
     if(widget.index != null){
       List<Map<String, dynamic>> recipes = await fetch.getRecipesByType(widget.index!);
       setState(() {
         widget.recipes = recipes;
         isLoading = false;
       });
     }  else {
       List<Map<String, dynamic>> recipes = await fetch.getAllRecipes();
       setState(() {
         widget.recipes = recipes;
         isLoading = false;
       });
     }
  }

  _loadImage(mealId, [recipeUrl]) {
    final imageBox = Hive.box('images');

    if (imageBox.containsKey(mealId)) {
      return imageBox.get(mealId);
    }
    else {
      final imageBytes = fetchImage(mealId, recipeUrl) as Uint8List;
    return imageBytes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserID>(context);
    final write = Write(uid: user.uid);
    if (!widget.swap && isLoading) {
      _fetch(user.uid);
    }
    if (widget.swap && widget.index != null && !loadfinished) {
      _fetchRecipes(user.uid, widget.index);
    }
    print(widget.index);


    final filteredRecipes = widget.recipes.where((recipe) {
      final name = recipe['name'];
      if (name == null || name.isEmpty) {
        print('Recipe with null or empty name: $recipe');
        return false;
      }
      final nameMatch = name.toLowerCase().contains(searchQuery.toLowerCase());
      if (!nameMatch) return false;

      switch (selectedFilter) {
        case 'Gluten-Free':
          return recipe['isGlutenFree'] == true;
        case 'Vegan':
          return recipe['isVegan'] == true;
        case 'Age Group':
          return recipe['ageGroup'] == '2-5 years';
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: isLoading
          ? _buildLoadingIndicator()
          : _buildRecipeList(filteredRecipes, write, User),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.grey[800]),
        onPressed: () => Navigator.pop(context),
      ),
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          onChanged: (value) => setState(() => searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search recipes...',
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: PopupMenuButton<String>(
            icon: Icon(Icons.tune, color: Colors.grey[800]),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) => setState(() => selectedFilter = value),
            itemBuilder: (context) => filterOptions.map((option) {
              return PopupMenuItem<String>(
                value: option,
                child: Row(
                  children: [
                    Icon(
                      option == selectedFilter ? Icons.check_circle : Icons.circle_outlined,
                      color: option == selectedFilter ? Colors.orange[700] : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(option),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[700]!),
      ),
    );
  }

  Widget _buildRecipeList(List<Map<String, dynamic>> recipes, Write write, user) {
    if (recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_meals, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No recipes found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recipes.length,
      itemBuilder: (context, index) => _buildRecipeCard(recipes[index], write, user),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe, Write write, user) {
    final connectivityNotifier = Provider.of<ConnectivityNotifier>(context);
    bool connected = connectivityNotifier.isConnected;

    return Card(
      margin: const EdgeInsets.only(bottom: 2), // Reduced margin
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0, // Reduced elevation for subtlety
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleRecipeTap(recipe, write),
        child: Row(
          children: [
            // Smaller image size
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child:_image(recipe['id'], recipe['imageUrl'])
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12), // Reduced padding
                child: Row(
                  children: [
                    // Recipe info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            recipe['name'],
                            style: const TextStyle(
                              fontSize: 14, // Smaller font
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          _buildRecipeAttributes(recipe),
                        ],
                      ),
                    ),
                    // Quick actions
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeAttributes(Map<String, dynamic> recipe) {
    return Wrap(
      spacing: 8,
      children: [
        if (recipe['isGlutenFree'] == true)
          _buildAttributeChip('Gluten-Free'),
        if (recipe['isVegan'] == true)
          _buildAttributeChip('Vegan'),
        if (recipe['ageGroup'] != null)
          _buildAttributeChip(recipe['ageGroup']),
      ],
    );
  }

  Widget _buildAttributeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.orange[700],
          fontSize: 12,
        ),
      ),
    );
  }

  void _handleRecipeTap(Map<String, dynamic> recipe, Write write) {
    // write.updateRecent(recipe['id']);

    final user = Provider.of<UserID>(context, listen: false);
    final updatedUserData = Hive.box('userData').get('userInfo');

    if (updatedUserData != null) {
      widget.userData?.updateUserData(
        uid: user.uid,
        recipeId: recipe['id'],
        isRecent: true,
      );
    }
    if (widget.swap) {
      _showSwapDialog(recipe, write, user.uid);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeDetailsPage(
            recipeID: recipe['id'],
            imageURL: recipe['imageUrl'],
            foodName: recipe['name'],
            ingredients: recipe['ingredients'],
            selected: widget.userData?.savedRecipes.contains(recipe['id']) ?? false,
          ),
        ),
      );
    }
  }

  void _showSwapDialog(Map<String, dynamic> recipe, Write write, String uid) {

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    height: MediaQuery.sizeOf(context).height * .7,
                    child: RecipeDetailsPage(
                      recipeID: recipe['id'],
                      imageURL: recipe['imageUrl'],
                      foodName: recipe['name'],
                      ingredients: recipe['ingredients'],
                      selected: widget.userData?.savedRecipes.contains(recipe['id']) ?? false,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, color: Colors.orange[700], size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Confirm Recipe Swap',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                        color: Colors.grey[600],
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel Button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Confirm Button
                  ElevatedButton(
                    onPressed: () {
                      print(recipesIndex);
                      Navigator.pop(context);
                      createCustomMealPlanWithSwap(
                        weeklyPlan,
                        recipe['id'],
                        recipesIndex,
                        widget.day!,
                        widget.child!,
                        widget.userData!.children,
                          widget.userData!
                      );
                      widget.userInfo!.updateUserData(
                        uid: uid,
                        recipeId: widget.meal['id'],
                        isRecent: true,
                      );
                      write.updateIngredients(recipe['ingredients'], widget.meal['ingredients']);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Confirm Swap',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _image(mealId, [recipeUrl]) {
    Uint8List imageBytes = _loadImage(mealId, recipeUrl);
    if (imageBytes != null) {
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        cacheWidth: 50, // Set the desired width
        cacheHeight: 50, // Set the desired height
      );
    } else {
      return Center(child: Text('No image'));
    }
  }

  String resizeImageUrl(String url, {int width = 50, int height = 50}) {
    if (url.contains('/upload/')) {
      return url.replaceFirst(
        '/upload/',
        '/upload/c_fill,w_${width},h_${height}/',
      );
    }
    return url;
  }
}