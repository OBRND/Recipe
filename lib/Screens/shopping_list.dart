import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meal/DataBase/state_mgt.dart';
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
      appBar: AppBar(
        title: Text('This is your shopping List for the week',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w300,
          color: Colors.white
        ),),
        backgroundColor: const Color.fromARGB(169, 126, 3, 3),
      ),
      body: StreamBuilder<DocumentSnapshot?>(
        stream: Shopping(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic> shoppingListData =
          snapshot.data?.data() as Map<String, dynamic>;

          if (shoppingListData == null || shoppingListData['ingredients'] == null) {
            return Center(child: Text("No ingredients available."));
          }

          Map<String, dynamic> ingredients = shoppingListData['ingredients'];

          return ListView.builder(
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              String ingredientName = ingredients.keys.elementAt(index);
              Map<String, dynamic> ingredient = ingredients[ingredientName];
              int quantity = ingredient['quantity'];
              String measurement = ingredient['unit'];
              bool isChecked = ingredient['isChecked'] ?? false;

              return ListTile(
                title: Text(
                  "$ingredientName - $quantity $measurement",
                  style: TextStyle(
                    decoration: isChecked
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                leading: Checkbox(
                  value: isChecked,
                  onChanged: (bool? newValue) {
                    // Update the shopping list item as bought/unbought
                    write.checkShopping(ingredientName, newValue);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

