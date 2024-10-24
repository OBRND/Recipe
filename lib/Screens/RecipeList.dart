import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../DataBase/Write_DB.dart';
import 'RecipeDetails.dart';

class RecipeList extends StatefulWidget {
  final List<Map<String, dynamic>> recipes;

  const RecipeList({required this.recipes});

  @override
  _RecipeListState createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  String searchQuery = '';
  String selectedFilter = 'All';
  List<String> filterOptions = ['All', 'Age Group', 'Gluten-Free', 'Vegan'];

  @override
  Widget build(BuildContext context) {
    final value = Provider.of<String>(context);
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
          decoration: InputDecoration(
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
      body: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredRecipes.length,
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    Write(uid: value).updateRecent(filteredRecipes[index]['id']);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailsPage(
                          recipeID: filteredRecipes[index]['id'],
                          imageURL:
                          'https://img.jamieoliver.com/jamieoliver/recipe-database/oldImages/large/576_1_1438868377.jpg?tr=w-800,h-1066',
                          foodName: filteredRecipes[index]['name'],
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
}
