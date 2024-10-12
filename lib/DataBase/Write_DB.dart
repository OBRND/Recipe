import 'package:cloud_firestore/cloud_firestore.dart';

class Write{

  final CollectionReference user = FirebaseFirestore.instance.collection('Users');

  Future addUser() async{
    return await user.doc('001').set({
      "Name" : "Jon"
    });
  }


}
