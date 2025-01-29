import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meal/Models/user_data.dart';
import 'package:meal/Models/user_id.dart';
import 'package:provider/provider.dart';
import '../DataBase/storage.dart';
import '../DataBase/write_db.dart';
import '../Screens/recipes/recipe_details.dart';
import 'color_model.dart';
import 'decoration.dart';

class MealCard extends StatefulWidget {
  bool home;
  var meal;
  int index;

  MealCard({required this.meal, required this.home,required this.index});

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  bool clicked = false;
  bool? temporarySavedState;
  Uint8List? _imageData;


  void _loadImage() async {
    Uint8List? imageData = await fetchImage(widget.meal['id'], resizeImageUrl(widget.meal['imageUrl']));
    if (mounted) {
      setState(() {
        _imageData = imageData;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant MealCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload the image if the meal or its image URL changes
    if (widget.meal['imageUrl'] != oldWidget.meal['imageUrl']) {
      _loadImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserDataModel?>(context);
    final user = Provider.of<UserID>(context);
    final bool saved = temporarySavedState ?? userInfo!.savedRecipes.contains(widget.meal['id']);

    return InkWell(
      onTap: () {
        final updatedUserData = Hive.box('userData').get('userInfo');
        print('*******************************');
        print(updatedUserData.toString());
        print('*******************************');

        if (updatedUserData != null) {
          Provider.of<UserDataModel>(context, listen: false).updateUserData(
            uid: user.uid,
            recipeId: widget.meal['id'],
            isRecent: true,
          );
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) =>
                    RecipeDetailsPage(
                      recipeID: widget.meal['id'],
                      imageURL: widget.meal['imageUrl'],
                      foodName: widget.meal['name'],
                      ingredients: widget.meal['ingredients'],
                      selected: userInfo?.savedRecipes.contains(widget.meal['id']) ?? false,
                    ),

          ),
        );
      },
      child: Container(
        height: MediaQuery.sizeOf(context).width / 2.8,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
        child: Stack(
            children: [
              Container(
                height: MediaQuery.sizeOf(context).width / 3.2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    decoration: boxDecoration,
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: MediaQuery.sizeOf(context).width / 2.8 + 10,
                              right: 10, top: 10, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.meal['name'],
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontSize: 16
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Perfect for family dinner',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.favorite, size: 16,
                                      color: Colors.orange[700]),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.meal['favoritesCount'].toString(),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.timer_outlined,
                                      size: 16,
                                      color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.meal['cookingTime'],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: -10,
                          child: IconButton(
                            onPressed: () async {
                              final updatedUserData = Hive.box('userData').get('userInfo');

                              if (updatedUserData != null) {
                                Provider.of<UserDataModel>(context, listen: false).updateUserData(
                                  uid: user.uid,
                                  recipeId: widget.meal['id'],
                                  isSaved: true,
                                  add: saved ? false : true,
                                );
                              }
                              setState(() {
                                clicked = true;
                                // Set the temporary state immediately to reflect the user's action.
                                temporarySavedState = !saved;
                              });

                              try {
                                if (saved) {
                                  await Write(uid: user.uid).removeSavedRecipe(widget.meal['id']);
                                } else {
                                  await Write(uid: user.uid).saveRecipe(widget.meal['id']);
                                }
                              } finally {
                                setState(() {
                                  clicked = false;
                                  // Clear the temporary state to rely on the Provider after the operation.
                                  temporarySavedState = null;
                                });
                              }
                            },
                            icon: clicked ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: Colors.red,
                              ),
                            )
                                : Icon(
                              saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              size: 20,
                              color: saved ? Colors.red : Colors.grey,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
             widget.home ? Stack(
                  children: [
                    Card(
                      elevation: 5,
                      margin: EdgeInsets.all(0),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width / 2.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          image: _imageData != null
                              ? DecorationImage(
                            fit: BoxFit.fill,
                            image: MemoryImage(_imageData!),
                          )
                              : DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(resizeImageUrl(widget.meal['imageUrl'])),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 25,
                      child: Center(
                        child: Text(
                          '${userInfo?.children[widget.index - 1]['name']}',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(15),
                          topLeft:  Radius.circular(12),
                        ),
                        color: ChildColorModel.colorOfChild(widget.index - 1).withOpacity(.8),
                      ),
                    ),
                  ]
              ) : Card(
               elevation: 5,
               margin: EdgeInsets.all(0),
               child: Container(
                 width: MediaQuery.sizeOf(context).width / 2.8,
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.all(Radius.circular(12)),
                   image: _imageData != null
                       ? DecorationImage(
                     fit: BoxFit.fill,
                     image: MemoryImage(_imageData!),
                   )
                       : DecorationImage(
                     fit: BoxFit.fill,
                     image: NetworkImage(resizeImageUrl(widget.meal['imageUrl'])),
                   ),
                 ),
               ),
             ),
            ]
        ),
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