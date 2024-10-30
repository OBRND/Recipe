import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal/DataBase/fetch_db.dart';

class Write{

  final String uid;
  Write({required this.uid});

  final CollectionReference user = FirebaseFirestore.instance.collection('Users');
  final CollectionReference Schedule = FirebaseFirestore.instance.collection('Schedule');

  Future addUser(String firstname, String email) async{
    List<Map<String, dynamic>> childInfo = [
      {
        'name': 'Alice',
        'ageGroup': 'infant',
        'dietPreference' : 'glutten free'
      },
      {
        'name': 'Bill',
        'ageGroup': 'children',
        'dietPreference' : 'Non spicy'
      },
    ];
    return await user.doc(uid).set({
      "name" : firstname,
      "children" : childInfo,
      'email' : email,
      'recent' : null,
      'savedRecipes' : null
    });
  }

  Future saveRecipe(String id) async{

    return await user.doc(uid).update({
      "savedRecipes" : FieldValue.arrayUnion([id])
    });
  }

  Future updateRecent(String id) async{

    return await user.doc(uid).update({
      "recent" : FieldValue.arrayUnion([id])
    });
  }

  // Method to clone the public meal plan
  Future<void> createCustomMealPlanWithSwap(
      List<Map<String, dynamic>> weeklyPlan,
      String newMealId,
      int mealIndex, // e.g., 0 for breakfast, 1 for lunch, etc.
      int dayIndex,   // e.g., 0 for Monday, 1 for Tuesday, etc.
      int child
      ) async {
    final userScheduleRef = Schedule.doc(uid);

    // Initialize a custom meal plan structured like the weekly plan

    Map<String, dynamic> childrenPlan = {};
    Map<String, List<DocumentReference>> customMealPlan;

    List<String> mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

    // Clone the weekly meal plan into the custom plan with reference format
    for (var children in weeklyPlan) {
      customMealPlan = {
        'breakfast': [],
        'lunch': [],
        'dinner': [],
        'snack': [],
      };
      for (var dayMeals in children.values) {
        for (var meal in dayMeals) {
          print('============');
          print(meal);
          print('============');
          print('============');
          print("Plan 1:" + "${weeklyPlan[0]}");
          print("Plan 2:" + "${weeklyPlan[1]}");
          print('============');

          String type = meal['mealType'];
          String mealId = meal['id'];
          var recipeRef = FirebaseFirestore.instance.doc('/Recipes/$mealId');

          if (customMealPlan[type] != null) {
            customMealPlan[type]!.add(recipeRef);
          }
        }
      }
      childrenPlan['${weeklyPlan.indexOf(children)}'] = customMealPlan;
    }

    // Swap the selected meal with the new meal ID on the specified day and meal type
    DocumentReference newRecipeRef = FirebaseFirestore.instance.doc('/Recipes/$newMealId');
    String mealType = mealTypes[mealIndex];

    // Ensure the custom meal plan is within bounds and replace the specific meal
    if (childrenPlan['$child'][mealType] != null && childrenPlan['$child'][mealType]!.length > dayIndex) {
      childrenPlan['$child'][mealType]![dayIndex] = newRecipeRef;
    }

    // Save the customized meal plan to Firestore under the user's UID
    await userScheduleRef.set(childrenPlan);
    print('Custom meal plan created with swap.');
  }



}
