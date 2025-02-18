import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:meal/DataBase/write_db.dart';
import 'package:provider/provider.dart';
import '../../DataBase/storage.dart';
import '../../Models/user_data.dart';
import '../../Models/user_id.dart';

class RecipeDetailsPage extends StatefulWidget {
  final String imageURL;
  final String recipeID;
  final String foodName;
  final bool selected;
  final List ingredients;
  final UserDataModel? userInfo;

  const RecipeDetailsPage({
    Key? key,
    required this.imageURL,
    required this.selected,
    required this.recipeID,
    required this.foodName,
    required this.ingredients,
    UserDataModel? this.userInfo,
  }) : super(key: key);

  @override
  _RecipeDetailsPageState createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> with SingleTickerProviderStateMixin{
  Color primaryColor = Colors.white;
  late AnimationController _controller;
  bool pressed = false;
  bool updatedRecent = false;
  Uint8List? _imageData;
  bool isFirst = true;
  final updatedUserData = Hive.box('userData').get('userInfo');

  void _loadImage() async {
    final imageData = await fetchImage(widget.recipeID, widget.imageURL);
    if (mounted) {
      setState(() {
        _imageData = imageData;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200), // Short duration for pop effect
      vsync: this,
      lowerBound: 1, // Slightly smaller scale
      upperBound: 1.5, // Slightly larger scale
    );
    _loadImage();
  }



  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserID>(context);
    Write write = Write(uid: user.uid);

    if(!updatedRecent) {
      write.updateRecent(widget.recipeID);
      updatedRecent = true;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(Icons.arrow_circle_left_rounded, size: 30)),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
        actions: [
        ScaleTransition(
        scale: _controller,
        child: IconButton(
          iconSize: 20,
          onPressed: () async {
            await _controller.forward();
            await _controller.reverse();
            if (updatedUserData != null) {
              widget.userInfo!.updateUserData(
                uid: user.uid,
                recipeId: widget.recipeID,
                isSaved: true,
                add: widget.selected || pressed ? false : true,
              );
            }
            // widget.selected ?
            // await Write(uid: user.uid).removeSavedRecipe(widget.recipeID) :
            // await Write(uid: user.uid).saveRecipe(widget.recipeID);
            setState(() {
              pressed = isFirst && widget.selected ? false : !pressed;
              isFirst = false;
            });
          },
          icon: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.5),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              isFirst && widget.selected || pressed ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isFirst && widget.selected || pressed ? Colors.red : Colors.grey,
            ),
          ),
        ),
              )
        ],
      ),
      body:
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with overlay
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              image: _imageData != null
                  ? DecorationImage(
                fit: BoxFit.cover,
                image: MemoryImage(_imageData!),
              ) : DecorationImage(
                  fit: BoxFit.cover,
                image: NetworkImage(widget.imageURL)),
              ),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(6, 6, 20, 6),
                    decoration: BoxDecoration(
                      color: Colors.black26.withOpacity(.7),
                      borderRadius: BorderRadius.only(topRight: Radius.circular(30)),
                    ),
                    child: Text(
                      widget.foodName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text('Instructions'),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.white.withOpacity(0.1),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: widget.ingredients.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: roww(index),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            widget.ingredients[index]['name'],
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
            widget.ingredients[index]['quantity'].toString() + ' ' +
            widget.ingredients[index]['unit'],
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

