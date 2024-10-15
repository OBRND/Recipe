import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meal/Screens/BottomNav.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
 

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   // Firebase.initializeApp();
    return StreamProvider<String>(
      create: (_) => Stream.value("001"),
      initialData: "0",
      child: MaterialApp(
      title: 'Meal planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: bottomNav()
     ) );
  }
}
