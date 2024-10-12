import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal/DataBase/Write_DB.dart';

class Fetch{

  final CollectionReference Recipee = FirebaseFirestore.instance.collection('Recipees');

  Future getRecipee() async{

    DocumentSnapshot recipee = await Recipee
        .doc('Shiro').get();
    print(recipee["cal"]);
    Write().addUser();
    return 0;
  }


}
