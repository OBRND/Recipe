import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:meal/Auth/auth_service.dart';
import 'package:meal/DataBase/fetch_db.dart';
import 'package:meal/Models/user_data.dart';
import 'package:meal/Screens/recipe_details.dart';
import 'package:provider/provider.dart';
import '../Models/user_id.dart';

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String name = "";
  int selected = DateTime.now().weekday;

  @override
  Widget build(BuildContext context) {
    final User = Provider.of<UserDataModel?>(context);
    final user = Provider.of<UserID>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(169, 126, 3, 3),
        title: Text(
            User == null ? "Welcome back " : "Welcome back " + User.name,
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(onPressed: () {
            AuthService().sign_out();
          }, icon: Icon(Icons.logout, color: Colors.white))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          EasyDateTimeLine(
            initialDate: DateTime.now(),
            onDateChange: (selectedDate) async {
              setState(() {
                selected = selectedDate.weekday;
              });
              print(selected);
              var data = await Fetch(uid: user.uid).getWeeklyMealPlan(
                  ['children', 'adults']);
              print('-------------------------------');
              print(data[0]);
            },
            headerProps: const EasyHeaderProps(
              monthPickerType: MonthPickerType.switcher,
              dateFormatter: DateFormatter.fullDateDMY(),
            ),
            dayProps: const EasyDayProps(
              height: 80,
              todayHighlightColor: Color.fromARGB(255, 252, 13, 13),
              todayStyle: DayStyle(
                  borderRadius: 30
              ),
              dayStructure: DayStructure.dayStrDayNum,
              activeDayStyle: DayStyle(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(208, 179, 12, 12),
                      Color(0xffe3dfdc),
                    ],
                  ),
                ),
              ),
              inactiveDayStyle: DayStyle(
                borderRadius: 32.0,
              ),
            ),
          ),
          Expanded(child: mealPlanWidget(context)),
        ],
      ),
    );
  }

  Widget mealPlanWidget(BuildContext context) {
    final user = Provider.of<UserID>(context);
    final userData = Provider.of<UserDataModel?>(context);
    Fetch fetch = Fetch(uid: user.uid);

    return SingleChildScrollView(
      child: FutureBuilder(
        future: fetch.getWeeklyMealPlan(['adults']),
        builder: (context, snapshot) {
          // Show loading indicator while fetching data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if there's an error
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading meal plan.'));
          }

          // Check if data is available
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final weeklyMealPlan = snapshot.data!;
            List<String> mealTypes = ['breakfast', 'lunch', 'snack', 'dinner'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: mealTypes.map((mealType) {
                // Extract all meals of the current type across all days and individuals
                List<Widget> mealWidgets = [];

                weeklyMealPlan.forEach((dayData) {
                  final mealsForDay = dayData["$selected"] as List<dynamic>;
                  final mealsOfType = mealsForDay.where((meal) => meal['mealType'] == mealType.toLowerCase()).toList();

                  mealsOfType.forEach((meal) {
                    mealWidgets.add(
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => Consumer<UserDataModel?>(
                                builder: (context, userData, child) {
                                  return RecipeDetailsPage(
                                    recipeID: meal['id'],
                                    imageURL:
                                    'https://img.jamieoliver.com/jamieoliver/recipe-database/oldImages/large/576_1_1438868377.jpg?tr=w-800,h-1066',
                                    foodName: meal['name'],
                                    ingredients: [
                                      Ingredient(name: 'pepper', measurement: '20 oz')
                                    ],
                                    selected: userData?.savedRecipes.contains(meal['id']) ?? false,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 100,
                          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                          child: Card(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0),
                                    image: const DecorationImage(
                                      image: NetworkImage(
                                          'https://img.jamieoliver.com/jamieoliver/recipe-database/oldImages/large/576_1_1438868377.jpg?tr=w-800,h-1066'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        meal['name'],
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        'Type: ${meal['mealType']}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                });

                // Only display the meal type if there are meals under it
                return mealWidgets.isNotEmpty
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Text(
                        mealType,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...mealWidgets,
                  ],
                )
                    : const SizedBox.shrink();
              }).toList(),
            );
          }

          // Show a message if no meals are found
          return const Center(child: Text('No meal plan found.'));
        },
      ),
    );
  }



}
