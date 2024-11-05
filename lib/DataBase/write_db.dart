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
      int mealIndex,
      int dayIndex,
      int child,
      List children,
      ) async {

    List childName = [];
    final userScheduleRef = Schedule.doc(uid);

    for(var childval in children){
      childName.add(childval['name']);
    }

    // Initialize a custom meal plan structured like the weekly plan
    Map<String, dynamic> childrenPlan = {};
    Map<String, List<DocumentReference>> customMealPlan;
    List<String> mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
    int index = 0;
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

          String type = meal['mealType'];
          String mealId = meal['id'];
          var recipeRef = FirebaseFirestore.instance.doc('/Recipes/$mealId');

          if (customMealPlan[type] != null) {
            customMealPlan[type]!.add(recipeRef);
          }
        }
      }
      childrenPlan[childName[index]] = customMealPlan;
      index ++;
    }

    // Swap the selected meal with the new meal ID on the specified day and meal type
    DocumentReference newRecipeRef = FirebaseFirestore.instance.doc('/Recipes/$newMealId');
    String mealType = mealTypes[mealIndex];

    // Ensure the custom meal plan is within bounds and replace the specific meal
    if (childrenPlan[childName[child]][mealType] != null && childrenPlan[childName[child]][mealType]!.length > dayIndex) {
      childrenPlan[childName[child]][mealType]![dayIndex - 1] = newRecipeRef;
    }

    // Save the customized meal plan to Firestore under the user's UID
    await userScheduleRef.set(childrenPlan);
    print('Custom meal plan created with swap.');
    await user.doc(uid).update({
      'swapped': FieldValue.increment(1),
      'custom' : true
    });
  }

  Future<void> addChild(Map childInfo, children) async {
    children.add(childInfo);

    await updateSchedule(childInfo['ageGroups'], childInfo['name']);
    // Update Firestore with the new list of children
    await user.doc(uid).update({'children': children});

  }

  Future updateSchedule(String ageGroup, String name) async{

    Map<String, dynamic> childPlan = {};
    Map<String, List<DocumentReference>> customMealPlan;
    customMealPlan = {
      'breakfast': [],
      'lunch': [],
      'dinner': [],
      'snack': [],
    };

    List weeklyPlan = await Fetch(uid: uid).getWeeklyPlan([ageGroup], false);
    print(weeklyPlan);
    for (var dayMeals in weeklyPlan) {
      for (var day in dayMeals.values) {
      for (var meal in day) {

        String type = meal['mealType'];
        String mealId = meal['id'];
        var recipeRef = FirebaseFirestore.instance.doc('/Recipes/$mealId');

        if (customMealPlan[type] != null) {
          customMealPlan[type]!.add(recipeRef);
        }
      }
      }
    }
    childPlan[name] = customMealPlan;

    return await Schedule.doc(uid).update({name : customMealPlan});
  }

}
