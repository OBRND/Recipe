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

  Future<void> addOrUpdateChild(Map<String, dynamic> childInfo, List<dynamic> children, {bool isEditing = false, Map<String, dynamic>? existingChild}) async {
    String childName = childInfo['name'];
    String childAgeGroup = childInfo['ageGroups'];
    bool updateMealPlan = false;

    // If editing, locate the existing child and update accordingly
    if (isEditing && existingChild != null) {
      String originalName = existingChild['name'];
      String originalAgeGroup = existingChild['ageGroups'];

      // Check if the age group has changed, requiring a meal plan update
      if (childAgeGroup != originalAgeGroup) {
        // Locate the index of the child to update in the list
        int childIndex = children.indexWhere((child) => child['name'] == originalName);
        print('childIndex:');
        print(childIndex);

        if (childIndex != -1) {
          // Remove the child from the local list
          children.removeAt(childIndex);
          // Re-add with updated info
          children.insert(childIndex, childInfo);

          // Update Firestore with the modified list
          await user.doc(uid).update({'children': children});

          updateMealPlan = true;
        }
      }

      // Update existing child’s info in children list
      int childIndex = children.indexWhere((child) => child['name'] == originalName);
      if (childIndex != -1) {
        children[childIndex] = childInfo;
      }

      // If the name has changed, remove the old meal plan under the old name
      if (originalName != childName) {
        await Schedule.doc(uid).update({originalName: FieldValue.delete()});
      }
    } else {
      // If adding a new child
      children.add(childInfo);
      updateMealPlan = true;
    }

    // Update meal plan if required
    if (updateMealPlan) {
      await updateSchedule(childAgeGroup, childName);
    }

    // Update Firestore with the updated children list
    await user.doc(uid).update({'children': children});
  }

  Future updateSchedule(String ageGroup, String name) async {
    Map<String, List<DocumentReference>> customMealPlan = {
      'breakfast': [],
      'lunch': [],
      'dinner': [],
      'snack': [],
    };

    // Fetch the weekly plan for the specified age group
    List weeklyPlan = await Fetch(uid: uid).getWeeklyPlan([ageGroup], false);

    // Populate customMealPlan from weeklyPlan
    for (var dayMeals in weeklyPlan) {
      for (var day in dayMeals.values) {
        for (var meal in day) {
          String type = meal['mealType'];
          String mealId = meal['id'];
          var recipeRef = FirebaseFirestore.instance.doc('/Recipes/$mealId');
          customMealPlan[type]?.add(recipeRef);
        }
      }
    }

    // Update the child’s custom meal plan in Firestore
    return await Schedule.doc(uid).update({name: customMealPlan});
  }


}
