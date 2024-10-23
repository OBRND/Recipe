import 'package:flutter/material.dart';
import 'package:meal/DataBase/Write_DB.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

import '../DataBase/Fetch_DB.dart';

class RecipeDetailsPage extends StatefulWidget {
  final String imageURL;
  final String recipeID;
  final String foodName;
  final List<Ingredient> ingredients;

  const RecipeDetailsPage({
    Key? key,
    required this.imageURL,
    required this.recipeID,
    required this.foodName,
    required this.ingredients,
  }) : super(key: key);

  @override
  _RecipeDetailsPageState createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  Color primaryColor = Colors.white;
  bool pressed = false;

  @override
  void initState() {
    super.initState();
   }

  @override
  Widget build(BuildContext context) {
    final value = Provider.of<String>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
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
        actions: [
          IconButton(onPressed: () {
            Write(uid: value).saveRecipe(widget.recipeID);
            setState(() {
              pressed = true;
            });
          },
              icon: Icon(pressed == true ? Icons.favorite : Icons.favorite_border))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with overlay
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.imageURL),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.6),
                    Colors.white.withOpacity(0.1),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.foodName,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.white.withOpacity(0.1),
              child: ListView.builder(
                itemCount: widget.ingredients.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text('Instructions'),
                        ),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),
                        roww(index),

                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget roww(int index){
    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            widget.ingredients[index].name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            widget.ingredients[index].measurement,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );

  }

}

class Ingredient {
  final String name;
  final String measurement;

  Ingredient({
    required this.name,
    required this.measurement,
  });
}
