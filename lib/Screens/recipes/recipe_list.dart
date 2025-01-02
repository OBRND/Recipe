import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../DataBase/fetch_db.dart';
import '../../DataBase/write_db.dart';
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
  });

  @override
  State<RecipeList> createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  String searchQuery = '';
  String selectedFilter = 'All';
  final List<String> filterOptions = ['All', 'Age Group', 'Gluten-Free', 'Vegan'];
  late bool isLoading;
  int recipesIndex = 0;
  List<Map<String, dynamic>> weeklyPlan = [];

  @override
  void initState() {
    super.initState();
    isLoading = widget.swap;
  }

  Future<void> _fetchRecipes(String uid, int? index) async {
    if (index == null) return;

    final fetched = await Fetch(uid: uid).getRecipesByType(index);

    if (mounted) {
      setState(() {
        weeklyPlan = widget.recipes;
        widget.recipes = fetched;
        isLoading = false;
        recipesIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserID>(context);
    final write = Write(uid: user.uid);

    if (widget.swap && widget.index != null) {
      _fetchRecipes(user.uid, widget.index);
    }

    final filteredRecipes = widget.recipes.where((recipe) {
      final nameMatch = recipe['name'].toLowerCase().contains(searchQuery.toLowerCase());
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
          : _buildRecipeList(filteredRecipes, write),
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

  Widget _buildRecipeList(List<Map<String, dynamic>> recipes, Write write) {
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
      itemBuilder: (context, index) => _buildRecipeCard(recipes[index], write),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe, Write write) {
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
                child: Image.network(
                  resizeImageUrl(recipe['imageUrl']),
                  width: 50, // Reduced width
                  height: 50, // Reduced height
                  fit: BoxFit.cover,
                ),
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
    write.updateRecent(recipe['id']);

    if (widget.swap) {
      _showSwapDialog(recipe, write);
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

  void _showSwapDialog(Map<String, dynamic> recipe, Write write) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Confirm Swap'),
        content: RecipeDetailsPage(
          recipeID: recipe['id'],
          imageURL: recipe['imageUrl'],
          foodName: recipe['name'],
          ingredients: recipe['ingredients'],
          selected: widget.userData?.savedRecipes.contains(recipe['id']) ?? false,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              write.createCustomMealPlanWithSwap(
                weeklyPlan,
                recipe['id'],
                recipesIndex,
                widget.day!,
                widget.child!,
                widget.userData!.children,
              );
              write.updateIngredients(recipe['ingredients'], widget.meal['ingredients']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm Change'),
          ),
        ],
      ),
    );
  }

  String resizeImageUrl(String url, {int width = 400, int height = 400}) {
    if (url.contains('/upload/')) {
      return url.replaceFirst(
        '/upload/',
        '/upload/c_fill,w_${width},h_${height}/',
      );
    }
    return url;
  }
}