import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../Models/user_data.dart';

Stream<UserDataModel?> userStream(String userId) {
  final userBox = Hive.box('userData');
  return FirebaseFirestore.instance.collection('Users').doc(userId)
      .snapshots().map((snapshot) {

    if (snapshot.exists) {
      final userData = UserDataModel.fromMap(snapshot.data()!);
      userBox.put('userInfo', userData.toMap());
      return userData;
    }
    return null;
  });
}

Stream<DocumentSnapshot?> Shopping(String uid) {
  return FirebaseFirestore.instance
      .collection('Shopping_list')
      .doc(uid)
      .snapshots();
}