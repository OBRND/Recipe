import 'package:cloud_firestore/cloud_firestore.dart';
import 'write_db.dart';

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
    String name = User_Profile["name"];
    return name;
  }

  Future getShoppinglist() async{
    DocumentSnapshot Shoppinglist = await Shopping
        .doc('$uid').get();
    String list = Shoppinglist[""];
    return list;
  }

  Future getPublicschedule() async{

    DocumentSnapshot Publicscheduled = await Schedule
        .doc('Public').get();
    List schedule = Publicscheduled[""];

    return 0;
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

  Future<List<Map<String, dynamic>>> getAllRecipes() async {
    try {
      QuerySnapshot querySnapshot = await Recipe.get();

      // Map each document's data into a list of maps
      List<Map<String, dynamic>> recipes = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>
        };
      }).toList();
      print(recipes);

      return recipes;
    } catch (e) {
      print('Error fetching recipes: ${e.toString()}');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecipesByType(int index) async {

    List<String> mealTypes = ['breakfast', 'main dish', 'dessert', 'snack'];

    if (index < 0 || index >= mealTypes.length) {
      print('Invalid index. Please provide a value between 0 and ${mealTypes
          .length - 1}.');
      return [];
    }
    String selectedMealType = mealTypes[index];

    List<Map<String, dynamic>> allRecipes = await getAllRecipes();

    List<Map<String, dynamic>> filteredRecipes = allRecipes.where((recipe) {
      return recipe['course'] ==
          selectedMealType;
    }).toList();
    print(filteredRecipes);
    return filteredRecipes;
  }

  Future<Map<String, dynamic>> getRecipe(String recipeId) async{

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

  Future getSavedRecipes(List Ids) async {

   List recipeIds = Ids;

   if (recipeIds.isEmpty) {
     print("No data");
     return [];
   }

   List<Map<String, dynamic>> recipes = await Future.wait(
     recipeIds.map((id) async {
       Map recipeDetails = await getRecipe(id);
       return {
         'id': id,
         'name': recipeDetails['name'],
         'cal': recipeDetails['cal']
       };
     }).toList(),
   );

   return recipes;
 }


 Future<List<Map<String, List<Map<String, dynamic>>>>> getWeeklyPlan(List ageGroups, bool custom) async {

    DocumentSnapshot publicScheduleSnapshot = await Schedule.doc('Public').get();
    DocumentSnapshot customScheduleSnapshot = await Schedule.doc(uid).get();

   List<Map<String, List<Map<String, dynamic>>>> multiplePlan = [];
   List<String> mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
   List<DocumentReference> allMealRefs = [];

   for (String ageGroup in ageGroups) {
     Map<String, dynamic> ageGroupData = custom ? customScheduleSnapshot[ageGroup] : publicScheduleSnapshot[ageGroup] ?? {};
     Map<String, List<Map<String, dynamic>>> weeklyMealPlan = {};

     // Collect all meal references
     for (String mealType in mealTypes) {
       List<dynamic> mealRefs = ageGroupData[mealType] ?? [];
       allMealRefs.addAll(mealRefs.cast<DocumentReference>());
     }

     // Fetch all recipe details in one go
     List<DocumentSnapshot> recipeSnapshots = await Future.wait(
         allMealRefs.map((ref) => ref.get()));

     // Create a map of recipe ID to data for easy lookup
     Map<String, Map<String, dynamic>> recipeDataMap = {
       for (var snapshot in recipeSnapshots)
         if (snapshot.exists) snapshot.id: snapshot.data() as Map<
             String,
             dynamic>
     };

     // Ensure each day has breakfast, lunch, dinner, and snack
     // Store separate indices for each meal type to ensure cycling through recipes in their order
     Map<String, int> mealTypeIndices = {
       'breakfast': 0,
       'lunch': 0,
       'dinner': 0,
       'snack': 0,
     };

     for (int day = 1; day <= 7; day++) {
       List<Map<String, dynamic>> dailyMeals = [];

       for (String mealType in mealTypes) {
         List<dynamic> mealRefs = ageGroupData[mealType] ?? [];
         if (mealRefs.isEmpty) continue;

         // Get the index for the current meal type and fetch the appropriate recipe reference
         int currentIndex = mealTypeIndices[mealType]!;
         DocumentReference recipeRef = mealRefs[currentIndex % mealRefs.length];
         Map<String, dynamic>? recipeData = recipeDataMap[recipeRef.id];

         // If recipe data exists, add it to the daily meals list and increment the index
         if (recipeData != null) {
           // Create a copy of the recipe data to avoid modifying the original map.
           Map<String, dynamic> recipeCopy = Map.from(recipeData);
           recipeCopy['mealType'] = mealType;
           recipeCopy['id'] = recipeRef.id;
           dailyMeals.add(recipeCopy);

           // Update the index for the meal type to move to the next recipe in the next cycle
           mealTypeIndices[mealType] = ((currentIndex) % mealRefs.length) + 1;
         }
       }

       weeklyMealPlan['$day'] = dailyMeals;
     }

     multiplePlan.add(weeklyMealPlan);
   }

   return multiplePlan;
 }











}
