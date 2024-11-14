import 'package:flutter/material.dart';
import 'package:meal/DataBase/write_db.dart';
import 'package:provider/provider.dart';

import '../DataBase/fetch_db.dart';
import '../Models/user_id.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key});

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserID>(context);
    Write write = Write(uid: user.uid);

    return Scaffold(
      body: FutureBuilder(
          future: Write(uid: user.uid).addOrUpdateShoppingList(),
          builder: (context, snapshot) {
        return Text(snapshot.toString());
          }),
    );
  }
}
