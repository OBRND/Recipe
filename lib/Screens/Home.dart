import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:meal/DataBase/Fetch_DB.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String name = "";

  @override
  Widget build(BuildContext context) {
    final value = Provider.of<String>(context);
    Fetch getname = Fetch(uid: value);

    Future display() async{
      String info = await getname.getUserInfo();
      return info;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(169, 126, 3, 3),
        title: FutureBuilder(
          future: display(),
          builder: (context, snapshot) {
             if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: 
                  Text("Welcome back", style: TextStyle(color: Colors.white)),); 
              } else if (snapshot.hasError) {
                return Text('We have encountered an error');
                } else {
                  final name = snapshot.data!;
                  return Center(child: 
                  Text("Welcome back " + name, style: TextStyle(color: Colors.white)),);
                  }
                  }
                  ),
                    ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          EasyDateTimeLine(
            initialDate: DateTime.now(),
            onDateChange: (selectedDate) async{
              await Fetch(uid: value).getRecipee();
              print(selectedDate);
              await Fetch(uid: value).getAllRecipes();
              //`selectedDate` the new date selected.
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
          )
        ],
      ),
    );
  }
}
