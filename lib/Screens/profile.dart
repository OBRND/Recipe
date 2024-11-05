import 'package:flutter/material.dart';
import 'package:meal/DataBase/write_db.dart';
import 'package:provider/provider.dart';

import '../Models/user_data.dart';
import '../Models/user_id.dart';
import '../Theme/themeNotifier.dart';

class Profile extends StatefulWidget {

  List info;

  Profile({required this.info});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _isDarkTheme = false;

  // Toggle theme function
  void _toggleTheme(bool value) {
    setState(() {
      _isDarkTheme = value;
    });
    Provider.of<ThemeNotifier>(context, listen: false).setTheme(value ? ThemeData.dark() : ThemeData.light());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // Theme toggle
          SwitchListTile(
            title: Text('Dark Theme'),
            value: _isDarkTheme,
            onChanged: _toggleTheme,
          ),
          SizedBox(height: 16.0),

          // Display and manage children info
          Text(
            'Children Info',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          ...widget.info
              .asMap()
              .entries
              .map((entry) {
            int index = entry.key;
            var child = entry.value;
            return ListTile(
              title: Text('${child['name']} (Age: ${child['age']})'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () =>
                    _showChildDialog(context, childData: child, index: index),
              ),
            );
          }).toList() ?? [],
          SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: () => _showChildDialog(context),
            child: Text('Add Child'),
          ),
        ],
      ),
    );
  }

  Future<void> _showChildDialog(BuildContext context,
      {Map<String, dynamic>? childData, int? index}) async {
    final nameController = TextEditingController(text: childData?['name']);
    final ageController = TextEditingController(text: childData?['age']);
    final user = Provider.of<UserID>(context, listen: false);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(childData == null ? 'Add Child' : 'Edit Child'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async{
                print(widget.info);
                if (childData == null) {
                  await Write(uid: user.uid).addChild({
                    'name' : nameController.text,
                    'age' : int.parse(ageController.text),
                    'ageGroups' : 'adults',
                    'dietPreference' : 'None'
                  }, widget.info);
                }
                // else {
                //   // Update existing child
                //   Provider.of<UserDataModel>(context, listen: false).updateChild(index!, {
                //     'name': nameController.text,
                //     'age': ageController.text,
                //   });
                // }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }


}

