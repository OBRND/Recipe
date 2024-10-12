import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Screens/Home.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   // Firebase.initializeApp();
    return MaterialApp(
      title: 'Meal planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'What do you have planned'),
    );
  }
}
