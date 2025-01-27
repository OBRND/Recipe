import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../Models/user_data.dart';

Stream<UserDataModel?> userDataStream(String uid) async* {
  final userBox = Hive.box('userData');

  // Load from Hive first
  final cachedData = userBox.get('userInfo');
  if (cachedData != null) {
    yield UserDataModel.fromMap(Map<String, dynamic>.from(cachedData));
  }

  // Listen to Firebase for updates
  await for (var snapshot in FirebaseFirestore.instance.collection('Users').doc(uid).snapshots()) {
    if (snapshot.exists) {
      final userData = UserDataModel.fromMap(snapshot.data()!);

      // Cache the latest data in Hive
      userBox.put('userInfo', userData.toMap());
      print('==============================');
      print(cachedData.toString());
      print('==============================');
      yield userData; // Emit the updated user data
    }
  }
}

Stream<DocumentSnapshot?> Shopping(String uid) {
  return FirebaseFirestore.instance
      .collection('Shopping_list')
      .doc(uid)
      .snapshots();
}