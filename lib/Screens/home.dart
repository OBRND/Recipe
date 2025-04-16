import 'dart:developer';

import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meal/Models/meal_card.dart';
import 'package:meal/Models/user_data.dart';
import 'package:meal/Screens/profile.dart';
import 'package:meal/Screens/recipes/recipe_list.dart';
import 'package:meal/Screens/shopping_list.dart';
import 'package:provider/provider.dart';
import '../Models/connection.dart';
import '../Models/user_id.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with AutomaticKeepAliveClientMixin{
  @override
  bool get wantKeepAlive => true; // Keeps the state alive
  String name = "";
  int selected = DateTime.now().weekday;
  int index = 0;
  List<Map<String, dynamic>> _cachedRecipes = [];
  late Future<List<Map<String, dynamic>>> _recipeFuture;
  bool _isLoading = false;
  bool first = true;
  int swapped = 0;

  void _loadRecipes(String uid, List<String> ageGroups, bool custom, int swap) {
    print('Reloading recipes...');
    final recipesBox = Hive.box('recipes');
    // log(recipesBox.getAt(0).toString());

    // Always load from Hive
    _recipeFuture = Future(() async {
      final cachedData = recipesBox.get('weeklyPlan');

      if (cachedData != null) {
        return (cachedData as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      } else {
        return <Map<String, dynamic>>[]; // Return an empty list if no cached data
      }
    }).then((cachedRecipes) {
      setState(() {
        _cachedRecipes = cachedRecipes;
        _isLoading = true;
        swapped = swap;
        if (first) {
          first = false;
        }
      });
      return cachedRecipes;
    });
  }


  void checkHiveDatabase() async {
    final box = await Hive.openBox('recipes');
    final storedData = box.get('weeklyPlan');

    if (storedData != null) {
      print("Stored Recipes in Hive:");
      for (var recipe in storedData) {
        print(recipe);
      }
    } else {
      print("No recipes found in Hive.");
    }
  }


  @override
  void initState() {
    super.initState();
    checkHiveDatabase(); // Check and display stored recipes in the terminal
  }


  @override
  Widget build(BuildContext context) {
    final UserInfo = Provider.of<UserDataModel?>(context);
    final user = Provider.of<UserID>(context);
    super.build(context);
    List<String> ageGroups = [];
    if (UserInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }
    for(int i = 0 ; i < UserInfo.children.length; i++) {
      UserInfo.custom ? ageGroups.add(UserInfo.children[i]['name']) :
      ageGroups.add(UserInfo.children[i]['ageGroups']);
    }
    if(first){
      _loadRecipes(user.uid, ageGroups, UserInfo.custom, UserInfo.swapped);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.of(context).push(
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  Consumer<UserDataModel?>(
                    builder: (BuildContext context, UserDataModel? value,
                        Widget? child) {
                      return Profile(info: UserInfo.children,);
                    },
                  )),);
          },
            icon: Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                  color: Colors.black.withOpacity(0.7)
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Padding(
              padding: EdgeInsets.all(2.0),
              child: Icon(Icons.person_outline_rounded),
            ))),
        title: const Text(
            "Meals for the day",
            style: TextStyle(color: Color.fromARGB(255, 39, 32, 34), fontWeight: FontWeight.w300, fontSize: 18)),
        actions: [
          IconButton(onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      const ShoppingList()));
          },
              icon: const Icon(Icons.shopping_cart_outlined))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: EasyDateTimeLine(
              activeColor: Colors.transparent,
              initialDate: DateTime.now(),
              onDateChange: (selectedDate) async {
                setState(() {
                  selected = selectedDate.weekday;
                });
              },
              timeLineProps: EasyTimeLineProps(
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                // color: Colors.grey[300],
              ),
              ),
              headerProps: const EasyHeaderProps(
                showMonthPicker: false,
                showHeader: false,
                monthPickerType: MonthPickerType.switcher,
                dateFormatter: DateFormatter.fullDateDMY(),
              ),
              dayProps: const EasyDayProps(
                inactiveDayStrStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                activeDayStrStyle: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                todayStrStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                inactiveDayNumStyle: TextStyle(fontSize: 12, color: Colors.grey),
                activeDayNumStyle: TextStyle(fontSize: 12, color: Colors.white),
                todayNumStyle: TextStyle(fontSize: 12),
                height: 58,
                width: 58,
                todayHighlightColor: Color(0xff9da50a),
                todayStyle: DayStyle(
                    borderRadius: 50
                ),
                dayStructure: DayStructure.dayStrDayNum,
                activeDayStyle: DayStyle(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    color: Color.fromARGB(219, 243, 38, 7)
                  ),
                ),
                inactiveDayStyle: DayStyle(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                      color: Colors.white
                  ),
                  borderRadius: 50.0,
                ),
              ),
            ),
          ),
          Expanded(child: mealPlanWidget(context, swapped, selected)),
        ],
      ),
    );
  }

  Widget mealPlanWidget(BuildContext context, int swapped, selected) {
    final user = Provider.of<UserID>(context);
    final userInfo = Provider.of<UserDataModel?>(context);
    List<String> ageGroups = [];
    final connectivityNotifier = Provider.of<ConnectivityNotifier>(context, listen: false);
    final isOnline = connectivityNotifier.isConnected;

    if (userInfo == null) {
      // Show a loading indicator while waiting for the user data.
      return const Center(child: CircularProgressIndicator());
    }

    for(int i = 0 ; i < userInfo.children.length; i++) {
      userInfo.custom ? ageGroups.add(userInfo.children[i]['name']) :
      ageGroups.add(userInfo.children[i]['ageGroups']);
    }

    if((!_isLoading || swapped < userInfo.swapped)) {
      _loadRecipes(user.uid, ageGroups, userInfo.custom, userInfo.swapped);
    }
      return SingleChildScrollView(
        child: FutureBuilder(
          future: _recipeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show cached recipes while waiting for fresh data
              if (_cachedRecipes.isNotEmpty) {
                final weeklyPlan = _cachedRecipes;
                return _buildMealPlanUI(weeklyPlan, ageGroups, userInfo, selected);
              }
              // If no cached data, show loading indicator
              return const Center(child: CircularProgressIndicator());
            }

            // Handle errors
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading meal plan.'));
            }

            // Load data if available
            if (snapshot.hasData && snapshot.data != null) {
              final weeklyPlan = snapshot.data!;
              return _buildMealPlanUI(weeklyPlan, ageGroups, userInfo, selected);
            }

            // Fallback to cached data if available
            if (_cachedRecipes.isNotEmpty) {
              final weeklyPlan = _cachedRecipes;
              return _buildMealPlanUI(weeklyPlan, ageGroups, userInfo, selected);
            }

            return const Center(child: Text('No meal plan found.'));
          },
        )
      );
    }

  Widget _buildMealPlanUI(
      List<Map<String, dynamic>> weeklyPlan,
      List<String> ageGroups,
      UserDataModel userInfo,
      int selected,
      ) {
    List<String> mealTypes = ['breakfast', 'lunch', 'snack', 'dinner'];
    int index = 0;
    final userInfo = Provider.of<UserDataModel?>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: mealTypes.map((mealType) {
        index = 0;
        List<Widget> mealWidgets = [];

        weeklyPlan.forEach((dayData) {
          final mealsForDay = dayData["$selected"] as List<dynamic>;
          final mealsOfType = mealsForDay.where((meal) => meal['mealType'] == mealType.toLowerCase()).toList();

          mealsOfType.forEach((meal) {
            index++;
            mealWidgets.add(
              Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RecipeList(
                        recipes: weeklyPlan,
                        userData: userInfo,
                        swap: true,
                        index: mealType == 'breakfast' ? 0 : mealType == 'lunch' ? 1 : mealType == 'dinner' ? 2 : 3,
                        meal: meal,
                        day: selected,
                        child: weeklyPlan.indexOf(dayData),
                        name: ageGroups,
                        // userInfo: userInfo,
                      ),
                    ),
                  );
                },
                background: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.swap_horiz, color: Colors.orange, size: 32),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: MealCard(key: ValueKey(meal['id']),meal: meal, home: true, index: index),
                ),
              ),
            );
          });
        });

        return mealWidgets.isNotEmpty
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                mealType,
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            ...mealWidgets,
          ],
        )
            : const SizedBox.shrink();
      }).toList(),
    );
  }

}
