import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal/DataBase/Write_DB.dart';

class Fetch{

 final String uid;
  Fetch({required this.uid});

  final CollectionReference Recipee = FirebaseFirestore.instance.collection('Recipees');
  final CollectionReference User = FirebaseFirestore.instance.collection('Users');

  Future getRecipee() async{

    DocumentSnapshot recipee = await Recipee
        .doc('Shiro').get();
    print(recipee["cal"]);
    Write().addUser();
    return 0;
  }

  Future getuserInfo() async{

    DocumentSnapshot User_Profile = await User
        .doc('$uid').get();
        // print(User_Profile["Name"]);
    String name = User_Profile["Name"];
    return name;
  }




}
