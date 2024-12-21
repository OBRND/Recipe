import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal/DataBase/fetch_db.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class Write{

  final String uid;
  Write({required this.uid});

  final CollectionReference user = FirebaseFirestore.instance.collection('Users');
  final CollectionReference Schedule = FirebaseFirestore.instance.collection('Schedule');
  final CollectionReference Shopping = FirebaseFirestore.instance.collection('Shopping_list');
  final CollectionReference Recipe = FirebaseFirestore.instance.collection('Recipes');

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
    UpdateShoppingList(false);
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
        updateMealPlan = true;
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

  Future deleteChild({required List<dynamic> children, required Map<String, dynamic> existingChild}) async {

    int childIndex = children.indexWhere((child) =>
    child['name'] == existingChild['name']);

    // Remove the child from the local list
    children.removeAt(childIndex);

    // Update Firestore with the modified list
    await user.doc(uid).update({'children': children});

    await Schedule.doc(uid).update({existingChild['name']: FieldValue.delete()});
  }

  Future<void> UpdateShoppingList(bool add) async {
    // Initialize a map to store ingredient totals for all children
    Map<String, Map<String, dynamic>> ingredientMap = {};

    // Fetch the current meal plan document for the user
    DocumentSnapshot scheduleSnapshot = await Schedule.doc(uid).get();
    Map<String, dynamic> scheduleData = scheduleSnapshot.data() as Map<String, dynamic>;

    if (scheduleData != null) {
      // Create a list to store all the future requests for recipe data
      List<Future<DocumentSnapshot>> recipeFutures = [];

      // Loop through the meal plan and collect all the recipe references
      for (var childName in scheduleData.keys) {
        Map<String, dynamic> childSchedule = scheduleData[childName];

        if (childSchedule != null) {
          for (var mealType in childSchedule.keys) {
            for (DocumentReference recipeRef in childSchedule[mealType]) {
              // Collect all the recipe references into a list
              recipeFutures.add(recipeRef.get());
            }
          }
        }
      }


      // Wait for all recipe references to be fetched at once
      List<DocumentSnapshot> recipeSnapshots = await Future.wait(recipeFutures);

      // Process the fetched recipe data
      for (var recipeSnapshot in recipeSnapshots) {
        Map<String, dynamic> recipeData = recipeSnapshot.data() as Map<String, dynamic>;

        print(recipeData);
        if (recipeData != null && recipeData['ingredients'] != null) {
          List ingredients = recipeData['ingredients'];

          for (var ingredient in ingredients) {
            String ingredientName = ingredient['name'];
            int quantity = ingredient['quantity'];
            String measurement = ingredient['measurement'];

            // Check if the ingredient is already in the map
            if (ingredientMap.containsKey(ingredientName)) {
              // Add the quantity if units match
              // if (ingredientMap[ingredientName]?['measurement'] == measurement) {
                ingredientMap[ingredientName]?['quantity'] += quantity;
                print(ingredientMap.length);
              // } else {
              //   // Handle unit mismatch if needed (optional: log or notify user)
              // }
            } else {
              // Add new ingredient entry
              ingredientMap[ingredientName] = {
                'quantity': quantity,
                'unit': measurement,
                'isChecked': false, // Default to not bought
              };
            }
          }
        }
    }
      //deletes a preexisting Shopping list before it adds the new one
      if(add){
        await Shopping.doc(uid).delete();
      }

  // Update the combined shopping list in Firestore
      await Shopping.doc(uid)
          .set({
        'ingredients': ingredientMap,
      }, SetOptions(merge: true));
    }
  }

// Function to handle marking items as bought
  Future<void> updateShoppingListItemStatus(String uid, String ingredientName, bool isChecked) async {
    DocumentReference shoppingListRef = FirebaseFirestore.instance.collection('Shopping_list').doc(uid);

    // Update the specific ingredient's status
    await shoppingListRef.update({
      'ingredients.$ingredientName.isChecked': isChecked,
    });
  }

  Future<void> updateIngredients(addedIngredients, removedIngredients) async {
    // Helper function to update the ingredient quantities in the current map
    print(addedIngredients.toString() + removedIngredients.toString());
    void updateQuantity(Map<String, dynamic> map, ingredients, bool isAdding) {
      for (var ingredient in ingredients) {
        String name = ingredient['name'];
        int quantity = ingredient['quantity'];
        String measurement = ingredient['measurement'];

        if (map.containsKey(name)) {
          map[name]['quantity'] += (isAdding ? quantity : -quantity);

          // Remove the ingredient if the quantity goes to zero or below
          if (map[name]['quantity'] <= 0) {
            map.remove(name);
          }
        } else if (isAdding) {
          // Add new ingredient to the map
          map[name] = {
            'quantity': quantity,
            'measurement': measurement,
            'isChecked': false, // Default value for new ingredients
          };
        }
      }
    }

    Map<String, dynamic> currentIngredients = await Fetch(uid: uid).shoppingList();
    // Update the current ingredients by adding and removing as needed
    updateQuantity(currentIngredients, addedIngredients, true);
    updateQuantity(currentIngredients, removedIngredients, false);

    // Reference to update the ingredient list in the database
    await Shopping.doc(uid).set({'ingredients' : currentIngredients});
  }

  Future checkShopping(ingredientName, newValue) async{
    return FirebaseFirestore.instance
        .collection('Shopping_list')
        .doc(uid)
        .update({
      'ingredients.$ingredientName.isChecked': newValue,
    });
  }

  Future addShoppingList(ingredientName, newValue) async{
    return Shopping
        .doc(uid)
        .update({
      'ingredients.$ingredientName': newValue,
    });
  }


  Future<void> saveRecipeDetails({
    required String name,
    required String cookingTime,
    required Set tags,
    required List ingredients,
    required List procedure,
    required String imageUrl,
    required String mealType,
    Set<String>? selectedPreferences,
    String? calories,
    String? videoUrl
  }) async {
    String recipeId = generateCode();
    try {
      await Recipe.doc(recipeId).set({
        'name': name,
        'mealType' : mealType,
        'cookingTime' : cookingTime,
        'tags' : tags,
        'ingredients': ingredients,
        'procedure': procedure,
        'imageUrl': imageUrl,
        'contributor': uid,
        'timestamp': FieldValue.serverTimestamp(),
        'preferences' : selectedPreferences,
        'calories' : calories,
        'videoUrl' : videoUrl
      });
      print('Recipe saved successfully!');
    } catch (e) {
      print('Error saving recipe: $e');
    }
  }

  String generateCode() {
    String datePart = DateFormat('ddMM').format(DateTime.now());
    String randomPart = Random().nextInt(1000).toString().padLeft(3, '0');

    return 'C$datePart$randomPart';
  }

}
