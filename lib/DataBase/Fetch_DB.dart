import 'package:cloud_firestore/cloud_firestore.dart';
import 'Write_DB.dart';

class Fetch{

 final String uid;
  Fetch({required this.uid});

  final CollectionReference Recipe = FirebaseFirestore.instance.collection('Recipes');
  final CollectionReference User = FirebaseFirestore.instance.collection('Users');
  final CollectionReference Shopping = FirebaseFirestore.instance.collection('Shopping_list');
  final CollectionReference Cookbook = FirebaseFirestore.instance.collection('Cookbook');
  final CollectionReference Schedule = FirebaseFirestore.instance.collection('Schedule');

  Future getUserInfo() async{

    DocumentSnapshot User_Profile = await User
        .doc('$uid').get();
<<<<<<< HEAD
    String name = User_Profile["name"];
=======
    String name = User_Profile["Name"];
>>>>>>> 41d996a0dd9bc1721f538056832e12eabf0331e5
    return name;
  }

  Future getShoppinglist() async{
<<<<<<< HEAD
=======

    DocumentSnapshot Shoppinglist = await Shopping
        .doc('$uid').get();
    String list = Shoppinglist[""];
    return list;
  }

  Future getMealschedule() async{

    DocumentSnapshot schedule = await Schedule
        .doc('$uid').get();
    Map dates = schedule['meals'];
    Map meals = dates['18/11/2024'];
    String recipeID = meals['breakfast'];

    return 0;
  }

  Future getPublicschedule() async{

    DocumentSnapshot Publicscheduled = await Schedule
        .doc('Public').get();
    List schedule = Publicscheduled[""];

    return 0;
  }

  Future getRecipe(String recipeId) async{

    DocumentSnapshot recipe = await Recipe
        .doc(recipeId).get();

    return 0;
  }

>>>>>>> 41d996a0dd9bc1721f538056832e12eabf0331e5

    DocumentSnapshot Shoppinglist = await Shopping
        .doc('$uid').get();
    String list = Shoppinglist[""];
    return list;
  }

  Future<Map<String, dynamic>> getMealschedule(String date) async {
  try {
    DocumentSnapshot schedule = await Schedule.doc('$uid').get();
    Map dates = schedule['meals'];
    
    if (!dates.containsKey(date)) {
      return {
        'error': 'No schedule found for the date: $date'
      };
    }

    Map meals = dates[date];

    String breakfastId = meals['breakfast'];
    String lunchId = meals['lunch'];
    String dinnerId = meals['dinner'];
    String snackId = meals['snacks'];

    Map breakfast = await getRecipe(breakfastId);
    Map lunch = await getRecipe(lunchId);
    Map dinner = await getRecipe(dinnerId);
    Map snacks = await getRecipe(snackId);
    
    print(breakfast['name'] + lunch['name']);

    return {
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'snacks': snacks,
    };
  } catch (e) {
    // Handle any potential errors and return an error message
    return {
      'error': 'Failed to fetch schedule: ${e.toString()}'
    };
  }
  }

  Future getPublicschedule() async{

    DocumentSnapshot Publicscheduled = await Schedule
        .doc('Public').get();
    List schedule = Publicscheduled[""];

    return 0;
  }

Future<List<Map<String, dynamic>>> getAllRecipes() async {
  try {
    QuerySnapshot querySnapshot = await Recipe.get();

    // Map each document's data into a list of maps
    List<Map<String, dynamic>> recipes = querySnapshot.docs.map((doc) {
      return {
        'id': doc.id, // Add the document ID if you need to keep track of it
        ...doc.data() as Map<String, dynamic> // Spread the data from each recipe document
      };
    }).toList();
    print(recipes);

    return recipes;
  } catch (e) {
    print('Error fetching recipes: ${e.toString()}');
    return [];
  }
}

  Future getRecipe(String recipeId) async{

    DocumentSnapshot recipe = await Recipe
        .doc(recipeId).get();
      String name = recipe['name'];  
      int cal = recipe['cal'];
      // String decription = recipe['discription'];
      // List ingredients = recipe['ingredients'];

    return {
      'name': name,
      'cal' : cal};
  }

}
