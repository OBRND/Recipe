import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:meal/DataBase/Fetch_DB.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xA9B86324),
        title: Center(child: Text(widget.title)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          EasyDateTimeLine(
            initialDate: DateTime.now(),
            onDateChange: (selectedDate) async{
              await Fetch().getRecipee();
              print(selectedDate);
              //`selectedDate` the new date selected.
            },
            headerProps: const EasyHeaderProps(
              monthPickerType: MonthPickerType.switcher,
              dateFormatter: DateFormatter.fullDateDMY(),
            ),
            dayProps: const EasyDayProps(
              height: 80,
              todayHighlightColor: Colors.deepOrangeAccent,
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
                      Color(0xffe3dfdc),
                      Color(0xffe8b276),
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
