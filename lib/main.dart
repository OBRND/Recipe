import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meal/Auth/auth_service.dart';
import 'package:meal/Models/user_id.dart';
import 'package:meal/Screens/Wrapper.dart';
import 'package:meal/Theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'Models/connection.dart';
import 'Models/user_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(UserDataModelAdapter());
  await Hive.openBox('recipes');
  await Hive.openBox('images');
  await Hive.openBox('userData');
  // debugRepaintRainbowEnabled = true;
  runApp(
    ChangeNotifierProvider(
        create: (_) => ConnectivityNotifier(),
        child: MyApp()),);
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
            theme: AppThemes.lightTheme,
            home: AuthWrapper()
        ));
  }
}
