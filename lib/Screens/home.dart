import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:meal/Auth/auth_service.dart';
import 'package:meal/Models/user_data.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String name = "";

  @override
  Widget build(BuildContext context) {
    final User = Provider.of<UserDataModel?>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(169, 126, 3, 3),
        title: Text(User == null ? "Welcome back " : "Welcome back " + User.name, style: TextStyle(color: Colors.white)),
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
            onDateChange: (selectedDate) async{
              print(selectedDate);
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
