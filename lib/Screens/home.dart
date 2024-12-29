import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:meal/DataBase/fetch_db.dart';
import 'package:meal/Models/meal_card.dart';
import 'package:meal/Models/user_data.dart';
import 'package:meal/Screens/profile.dart';
import 'package:meal/Screens/recipes/recipe_list.dart';
import 'package:meal/Screens/shopping_list.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final UserInfo = Provider.of<UserDataModel?>(context);
    final user = Provider.of<UserID>(context);
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.of(context).push(
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  Consumer<UserDataModel?>(
                    builder: (BuildContext context, UserDataModel? value,
                        Widget? child) {
                      return Profile(info: UserInfo!.children,);
                    },
                  )),
        );},
            icon: Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                  color: Colors.black.withOpacity(0.7)
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Icon(Icons.person_outline_rounded),
            ))),
        title: Text(
            UserInfo == null ? "Your plan" :
            "Hey " + UserInfo.name.substring(0,1).toUpperCase()+ UserInfo.name.substring(1) + ", here's your plan",
            style: TextStyle(color: Color.fromARGB(255, 39, 32, 34), fontWeight: FontWeight.w300, fontSize: 18)),
        actions: [
          IconButton(onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      ShoppingList()));
          },
              icon: Icon(Icons.shopping_cart_outlined))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: EasyDateTimeLine(
              initialDate: DateTime.now(),
              onDateChange: (selectedDate) async {
                setState(() {
                  selected = selectedDate.weekday;
                });
              },
              timeLineProps: EasyTimeLineProps(
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.grey[300],
              ),
              ),
              headerProps: const EasyHeaderProps(
                showMonthPicker: false,
                showHeader: false,
                monthPickerType: MonthPickerType.switcher,
                dateFormatter: DateFormatter.fullDateDMY(),
              ),
              dayProps: EasyDayProps(
                inactiveDayStrStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                activeDayStrStyle: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                todayStrStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                inactiveDayNumStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                activeDayNumStyle: const TextStyle(fontSize: 12, color: Colors.white),
                todayNumStyle: const TextStyle(fontSize: 12),
                height: 60,
                width: 60,
                todayHighlightColor: const Color(0xff9da50a),
                todayStyle: const DayStyle(
                    borderRadius: 50
                ),
                dayStructure: DayStructure.dayStrDayNum,
                activeDayStyle: const DayStyle(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    color: Color.fromARGB(219, 243, 38, 7)
                  ),
                ),
                inactiveDayStyle: DayStyle(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                      color: Colors.grey[200]
                  ),
                  borderRadius: 50.0,
                ),
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
    final userInfo = Provider.of<UserDataModel?>(context);
    Fetch fetch = Fetch(uid: user.uid);
    List<String> ageGroups = [];

    if (userInfo == null) {
      // Show a loading indicator while waiting for the user data.
      return Center(child: CircularProgressIndicator());
    }

    for(int i = 0 ; i < userInfo.children.length; i++) {
      userInfo.custom ? ageGroups.add(userInfo.children[i]['name']) :
      ageGroups.add(userInfo.children[i]['ageGroups']);
    }

    return SingleChildScrollView(
      child: FutureBuilder(
        future: fetch.getWeeklyPlan(ageGroups, userInfo.custom),
        builder: (context, snapshot) {
          // Show loading indicator while fetching data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if there's an error
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading meal plan.'));//make an alert dialogue box of this error  loading text
          }

          // Check if data is available
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final weeklyPlan = snapshot.data!;
            List<String> mealTypes = ['breakfast', 'lunch', 'snack', 'dinner'];
            print(snapshot.data);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: mealTypes.map((mealType) {
                index = 0;
                // Extract all meals of the current type across all days and individuals
                List<Widget> mealWidgets = [];

                weeklyPlan.forEach((dayData) {
                  final mealsForDay = dayData["$selected"] as List<dynamic>;
                  final mealsOfType = mealsForDay.where((meal) =>
                  meal['mealType'] == mealType.toLowerCase())
                      .toList();

                  mealsOfType.forEach((meal) {
                    index ++;
                    mealWidgets.add(
                        Dismissible(
                          key: UniqueKey(),
                          // Each Dismissible widget needs a unique key
                          direction: DismissDirection.endToStart,
                          // Specify swipe direction
                          onDismissed: (direction) {
                            print('---------');
                            print(weeklyPlan.indexOf(dayData));
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      RecipeList(
                                          recipes: weeklyPlan,
                                          userData: userInfo,
                                          swap: true,
                                          index: mealType == 'breakfast' ? 0 :
                                          mealType == 'lunch' ? 1 :
                                          mealType == 'dinner' ? 2 : 3,
                                          meal: meal,
                                          day: selected,
                                          child: weeklyPlan.indexOf(dayData),
                                          name: ageGroups
                                      )),
                            );
                          },
                          background: Container(
                            color: Colors.white, // Background color when swiped
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0),
                            alignment: Alignment.centerRight,
                            child: const Icon(
                              Icons.swap_horiz,
                              color: Colors.orange,
                              size: 32,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: MealCard(meal: meal, home: true, index: index),
                          ),
                        )
                    );
                  }
                  );
                }
                );

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
