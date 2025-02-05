import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meal/DataBase/write_db.dart';
import 'package:provider/provider.dart';
import '../Auth/auth_service.dart';
import '../Models/color_model.dart';
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
    final UserInfo = Provider.of<UserDataModel?>(context);
    final user = Provider.of<UserID>(context, listen: false);
    int marker = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Theme toggle
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
                children: [
                //   SwitchListTile(
                //   title: Text('Dark Theme',
                //     style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                //   ),
                //   activeColor: Colors.black38,
                //   value: _isDarkTheme,
                //   onChanged: _toggleTheme,
                // ),
                  CupertinoListTile(
                    title: Text(
                      'Dark Theme',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    trailing: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 50, // Match switch width
                          height: 30, // Match switch height
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: _isDarkTheme ? Colors.black54 : Colors.grey.shade300,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 4.0),
                                child: Icon(CupertinoIcons.sun_max_fill,
                                    size: 15, color: Colors.amber),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(CupertinoIcons.moon_fill,
                                    size: 15, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        // Actual switch (thumb moves over the icons)
                        CupertinoSwitch(
                          value: _isDarkTheme,
                          onChanged: (value) => _toggleTheme(value),
                          activeColor: Colors.transparent, // Hide default track color
                          trackColor: Colors.transparent,  // Hide default track color
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.0),
                  Text(
                    'Children Info',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  // Display and manage children info
                  Card(
                    margin: EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
                          ...widget.info
                              .asMap()
                              .entries
                              .map((entry) {
                            int index = entry.key;
                            var child = entry.value;
                            marker++;
                            return ListTile(
                              minVerticalPadding: 5,
                              horizontalTitleGap: 0,
                              leading: Container(
                                width: 8,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12)),
                                  color: ChildColorModel.colorOfChild(marker - 1),
                                ),
                              ),
                              title: Text(
                                  '${child['name']} (Age: ${child['age']})',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, size: 20,),
                                    onPressed: () =>
                                        _showChildDialog(
                                            context, childData: child,
                                            index: index),
                                  ),
                                  IconButton(
                                      icon: Icon(
                                          Icons.delete_forever,
                                          size: 25,
                                          color: Colors.red.shade600),
                                      onPressed: () =>
                                          _deleteChild(context, child)
                                  ),
                                ],
                              ),
                            );
                          }).toList() ?? [],
                          ElevatedButton(
                            onPressed: () => _showChildDialog(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, color: Colors.white, size: 22,),
                                Text('Add Child', style: TextStyle(fontSize: 12),),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 8.0),
                ]),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Container(

                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Color(0x47D6BEB8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0x6ED1D3A2), // Icon background color
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.language,
                          color: Colors.black87, // Icon color
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Language',
                          style: TextStyle(
                            color: Colors.black87, // Text color
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black54, // Arrow color
                        size: 14,
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(123, 230, 137, 137),
                    borderRadius: BorderRadius.circular(25), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: InkWell(
                    onTap: () {
                      AuthService().sign_out();
                    },
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0x7EDA6A6A), // Icon background color
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.logout,
                            color: Colors.red, // Icon color
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.red, // Text color
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteChild(BuildContext context, Map<String, dynamic> child){
    final user = Provider.of<UserID>(context, listen: false);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Child'),
          content: Text(
              'Are you sure you want to delete this child? This action will permanently delete the child and their associated schedule.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Dismiss the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await Write(uid: user.uid).deleteChild(children: widget.info, existingChild: child);
                setState(() {});
                Navigator.of(context)
                    .pop();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showChildDialog(BuildContext context,
      {Map<String, dynamic>? childData, int? index}) async {
    final nameController = TextEditingController(text: childData?['name']);
    final ageController = TextEditingController(text: childData?['age'].toString());
    final user = Provider.of<UserID>(context, listen: false);
    int index = 0;

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
                if (childData == null) {
                  await Write(uid: user.uid).addOrUpdateChild({
                    'name' : nameController.text,
                    'age' : int.parse(ageController.text),
                    'ageGroups' : 'children',
                    'dietPreference' : 'None'
                  }, widget.info);
                }
                else {
                  await Write(uid: user.uid).addOrUpdateChild({
                    'name': nameController.text,
                    'age': int.parse(ageController.text),
                    'ageGroups': 'children',
                    'dietPreference': 'None',
                  }, widget.info, isEditing: true, existingChild: childData);

                }
                Write(uid: user.uid).UpdateShoppingList(true);
                setState(() {});
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

