import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meal/Auth/auth_service.dart';
import 'package:meal/Models/user_id.dart';
import 'package:meal/Screens/Wrapper.dart';
import 'package:meal/Screens/bottom_nav.dart';
import 'package:provider/provider.dart';

import 'Theme/themeNotifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(ThemeData.light()),
      child: MyApp(),
    ),);
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
    return StreamProvider<UserID?>.value(
        value: AuthService().UserStream,
        initialData: null,
        child: MaterialApp(
            title: 'Meal planner',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: AuthWrapper()
        ));
  }
}
