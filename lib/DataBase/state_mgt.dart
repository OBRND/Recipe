import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/user_data.dart';

Stream<UserDataModel?> userStream(String userId) {
  return FirebaseFirestore.instance.collection('Users').doc(userId)
      .snapshots().map((snapshot) {

    if (snapshot.exists) {
      return UserDataModel.fromMap(snapshot.data()!);
    }
    return null;
  });
}