import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal/DataBase/Write_DB.dart';

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
    String name = User_Profile["Name"];
    return name;
  }

  Future getShoppinglist() async{

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




}
