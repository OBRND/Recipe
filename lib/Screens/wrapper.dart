import 'package:flutter/material.dart';
import 'package:meal/Auth/sign_in.dart';
import 'package:provider/provider.dart';

import '../DataBase/state_mgt.dart';
import '../Models/user_data.dart';
import '../Models/user_id.dart';
import 'bottom_nav.dart';

class AuthWrapper extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserID?>(context); // Fetches the authenticated user

    if (user == null) {
      return SignIn(); // Replace with your login screen widget
    }

    return MultiProvider(
      providers:[ StreamProvider<UserDataModel?>.value(
          lazy: false,
          value: userDataStream(user.uid),
          initialData: null,
          catchError: (_, __) => null,
          builder: (context, child) {
            return bottomNav();
          }),
      ]
    );
  }


}
