import 'package:flutter/material.dart';
import 'package:meal/DataBase/fetch_db.dart';
import 'package:meal/Models/user_id.dart';
import 'package:provider/provider.dart';
import '../DataBase/write_db.dart';
import '../Models/user_data.dart';
import 'recipe_details.dart';

class RecipeList extends StatefulWidget {
  List<Map<String, dynamic>> recipes;
  final UserDataModel? userData;
  final bool swap;
  int? index = null;
  int? day = null;
  int? child = null;
  Map meal = {};
  List? name = [];

  RecipeList({required this.recipes,required this.swap, required this.userData, required this.index, required this.meal, required this.day, required this.child, required this.name});

  @override
  _RecipeListState createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  String searchQuery = '';
  String selectedFilter = 'All';
  List<String> filterOptions = ['All', 'Age Group', 'Gluten-Free', 'Vegan'];
  bool isLoading = true;
  int recipesIndex = 0;
  List<Map<String, dynamic>> weeklyPlan = [];



  Future<void> _fetchRecipes(uid, index) async {

    List<Map<String, dynamic>> fetched = await Fetch(uid: uid).getRecipesByType(index);

    setState(() {
      weeklyPlan = widget.recipes;
      widget.recipes = fetched;
      isLoading = false;
      recipesIndex = widget.index!;
      widget.index  = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserID>(context);
    Write write = Write(uid: user.uid);
    if (widget.swap && widget.index != null) {
      _fetchRecipes(user.uid, widget.index);
    }
    List<Map<String, dynamic>> filteredRecipes = widget.recipes
        .where((recipe) =>
    recipe['name'].toLowerCase().contains(searchQuery.toLowerCase()) &&
        (selectedFilter == 'All' ||
            (selectedFilter == 'Gluten-Free' && recipe['isGlutenFree']) ||
            (selectedFilter == 'Vegan' && recipe['isVegan']) ||
            (selectedFilter == 'Age Group' &&
                recipe['ageGroup'] == '2-5 years'))) // Example age group
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_circle_left_rounded, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
        title: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search recipes...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black54),
            prefixIcon: Icon(Icons.search, color: Colors.black54),
          ),
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          DropdownButton<String>(
            value: selectedFilter,
            icon: Icon(Icons.filter_list, color: Colors.black),
            underline: Container(),
            dropdownColor: Colors.white,
            onChanged: (value) {
              setState(() {
                selectedFilter = value!;
              });
            },
            items: filterOptions.map<DropdownMenuItem<String>>((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option, style: TextStyle(color: Colors.black)),
              );
            }).toList(),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredRecipes.length,
                itemBuilder: (context, index) =>
                    InkWell(
                      onTap: () {
                        write.updateRecent(
                            filteredRecipes[index]['id']);
                        print(filteredRecipes[index]);
                        widget.swap == true ? _showSwapDialog(context, filteredRecipes, index,
                              () {
                            Navigator.pop(context);
                            write.createCustomMealPlanWithSwap(weeklyPlan, filteredRecipes[index]['id'],
                                recipesIndex, widget.day!, widget.child!, widget.userData!.children);
                            write.updateIngredients(filteredRecipes[index]['ingredients'], widget.meal['ingredients']);
                        }) :
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                RecipeDetailsPage(
                                  recipeID: filteredRecipes[index]['id'],
                                  imageURL:
                                  'https://img.jamieoliver.com/jamieoliver/recipe-database/oldImages/large/576_1_1438868377.jpg?tr=w-800,h-1066',
                                  foodName: filteredRecipes[index]['name'],
                                  ingredients: filteredRecipes[index]['ingredients'],
                                  selected: widget.userData!.savedRecipes
                                      .contains(filteredRecipes[index]['id'])
                                      ? true
                                      : false,
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
                                  filteredRecipes[index]['name'],
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
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showSwapDialog(BuildContext context, filteredRecipes, int index, Function onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Swap'),
          content: RecipeDetailsPage(
            recipeID: filteredRecipes[index]['id'],
            imageURL:
            'https://img.jamieoliver.com/jamieoliver/recipe-database/oldImages/large/576_1_1438868377.jpg?tr=w-800,h-1066',
            foodName: filteredRecipes[index]['name'],
            ingredients: filteredRecipes[index]['ingredients'],
            selected: widget.userData!.savedRecipes
                .contains(filteredRecipes[index]['id'])
                ? true
                : false,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onConfirm(); // Call the confirm function to handle swap logic
                Navigator.of(context).pop();
              },
              child: Text('Confirm change'),
            ),
          ],
        );
      },
    );
  }

}

