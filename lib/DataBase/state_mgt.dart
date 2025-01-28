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
      final userData = UserDataModel.fromMap(snapshot.data()!, true);
      // Update Hive cache
      await userBox.put('userInfo', userData.toMap());
    }
  });

  // Listen to Hive for changes and emit updates
  yield* userBox.watch(key: 'userInfo').map((event) {
    final updatedData = userBox.get('userInfo');
    print('********************');
    print(updatedData['recentRecipes'].toString());
    print('--------------------');
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