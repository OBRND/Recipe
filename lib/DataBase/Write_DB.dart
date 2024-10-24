import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal/DataBase/Fetch_DB.dart';

class Write{

  final String uid;
  Write({required this.uid});

  final CollectionReference user = FirebaseFirestore.instance.collection('Users');

  Future addUser() async{
    List<Map<String, dynamic>> childInfo = [
      {
        'name': 'Alice',
        'age': 8,
        'dietPreference' : 'glutten free'
      },
      {
        'name': 'Bill',
        'age': 12,
        'dietPreference' : 'Non spicy'
      },
    ];
    return await user.doc('001').set({
      "name" : "Jon",
      "children" : childInfo,
      'SavedRecipe' : '',
      'email' : '',
      'recent' : null,
      'savedRecipes' : null
    });
  }

  Future saveRecipe(String id) async{

    return await user.doc(uid).update({
      "savedRecipes" : FieldValue.arrayUnion([id])
    });
  }

  Future updateRecent(String id) async{

    return await user.doc(uid).update({
      "recent" : FieldValue.arrayUnion([id])
    });
  }

}
