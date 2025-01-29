import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../Models/user_data.dart';

Stream<UserDataModel?> userDataStream(String uid) async* {
  final userBox = Hive.box('userData');

  // Load cached data from Hive first
  if (userBox.containsKey('userInfo')) {
    final cachedData = userBox.get('userInfo');
    yield UserDataModel.fromMap(Map<String, dynamic>.from(cachedData), false);
  }

  // Listen to Firebase updates and update Hive
  FirebaseFirestore.instance.collection('Users').doc(uid).snapshots().listen((snapshot) async {
    if (snapshot.exists) {
      final firebaseData = UserDataModel.fromMap(snapshot.data()!, true);

      // Check if Hive data exists
      if (userBox.containsKey('userInfo')) {
        final hiveData = UserDataModel.fromMap(userBox.get('userInfo'), false);

        // Compare timestamps to determine the most recent data
        if (firebaseData.lastUpdated.isAfter(hiveData.lastUpdated)) {
          // Firebase data is newer, update Hive
          await userBox.put('userInfo', firebaseData.toMap());
        } else if (firebaseData.lastUpdated.isBefore(hiveData.lastUpdated)) {
          // Hive data is newer, update Firebase
          await FirebaseFirestore.instance.collection('Users').doc(uid).update(hiveData.toMap());
        }
        // If timestamps are equal, no action is needed
      } else {
        // No Hive data, update Hive with Firebase data
        await userBox.put('userInfo', firebaseData.toMap());
      }
    }
  });

  // Yield Hive updates
  yield* userBox.watch(key: 'userInfo').map((event) {
    final updatedData = userBox.get('userInfo');
    if (updatedData != null) {
      return UserDataModel.fromMap(Map<String, dynamic>.from(updatedData), false);
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