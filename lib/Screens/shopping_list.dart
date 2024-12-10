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

class _ShoppingListState extends State<ShoppingList> with AutomaticKeepAliveClientMixin{
  final _ingredientController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedMeasurement = 'kg';

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _ingredientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = Provider.of<UserID>(context);
    Write write = Write(uid: user.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your groceries for the week',),
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

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView.builder(
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                String ingredientName = ingredients.keys.elementAt(index);
                Map<String, dynamic> ingredient = ingredients[ingredientName];
                String unit = '';
                int quantity = 0;
                if(ingredient['unit'] == 'Grams' && ingredient['quantity'] > 1000){
                  unit = 'KG';
                  quantity = (ingredient['quantity'] / 1000).toInt();
                } else {
                  quantity = ingredient['quantity'];
                  unit = ingredient['unit'];
                }
                bool isChecked = ingredient['isChecked'] ?? false;

                return ListTile(
                  title: Text(
                    " $ingredientName",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: isChecked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: Text(" $quantity ${unit == 'full' ? 'Pcs' : unit}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: isChecked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  leading: Checkbox(
                    value: isChecked,
                    onChanged: (bool? newValue) {
                      write.checkShopping(ingredientName, newValue);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
          label: Container(
            width: 200,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(Icons.add, color: Colors.white),
                ),
                Text('Add to the shopping list', style: TextStyle(
                  color: Colors.white
                ),)
              ],
            ),
          ),
          onPressed: () {
            addIngredient(write);
      }),
    );
  }

  void addIngredient(Write write) {

    final _formKey = GlobalKey<FormState>();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Form(
            key: _formKey,
            child: AlertDialog(
              title: Text('Add Item to Shopping List',
              style: TextStyle(fontSize: 20),),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _ingredientController,
                    decoration: InputDecoration(labelText: 'Item Name'),
                    validator: (val) => val!.isEmpty ? 'Enter an Item' : null,
                  ),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    validator: (val) => val! is int || val.isNotEmpty ? null : 'Enter a valid number please',
                  ),
                  DropdownButton<String>(
                    value: _selectedMeasurement,
                    items: ['kg', 'g', 'L', 'ml', 'pcs'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedMeasurement = newValue!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    String ingredientName = _ingredientController.text;
                    if (_formKey.currentState!.validate()) {
                      int quantity = int.parse(_amountController.text);
                      Map newValue = {
                        'isChecked' : false,
                        'quantity' : quantity,
                        'unit' : _selectedMeasurement
                      };
                      write.addShoppingList(ingredientName, newValue);
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(
                            'Please enter valid item and amount')),
                      );
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          );
        }
    );
  }

}

