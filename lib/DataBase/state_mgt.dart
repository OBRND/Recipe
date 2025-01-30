import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../Models/user_data.dart';

Stream<UserDataModel?> userDataStream(String uid) async* {
  final userBox = Hive.box('userData');

  // Load cached data from Hive first
  if (userBox.containsKey('userInfo')) {
    final cachedData = userBox.get('userInfo');
    if (cachedData != null) {
      // Convert Map<dynamic, dynamic> to Map<String, dynamic>
      final convertedData = _convertMap(cachedData);
      yield UserDataModel.fromMap(convertedData, false);
    }
  }

  // Listen to Firebase updates and update Hive
  FirebaseFirestore.instance.collection('Users').doc(uid).snapshots().listen((snapshot) async {
    if (snapshot.exists) {
      final firebaseData = UserDataModel.fromMap(snapshot.data()!, true);
      final cachedData = userBox.get('userInfo');
        // Convert Map<dynamic, dynamic> to Map<String, dynamic>
        final convertedData = _convertMap(cachedData);
      final hiveData = UserDataModel.fromMap(convertedData, false);

      if (firebaseData.lastUpdated.isAfter(hiveData.lastUpdated)) {
        // Firebase data is newer, update Hive
        await userBox.put('userInfo', firebaseData.toMap());
      } else if (firebaseData.lastUpdated.isBefore(hiveData.lastUpdated)) {
        // Hive data is newer, update Firebase
        await FirebaseFirestore.instance.collection('Users').doc(uid).update(hiveData.toMap());
      }
    }
  });

  // Yield Hive updates
  yield* userBox.watch(key: 'userInfo').map((event) {
    final updatedData = userBox.get('userInfo');
    if (updatedData != null) {
      // Convert Map<dynamic, dynamic> to Map<String, dynamic>
      final convertedData = _convertMap(updatedData);
      return UserDataModel.fromMap(convertedData, false);
    }
    return null;
  });
}

// Helper function to convert Map<dynamic, dynamic> to Map<String, dynamic>
Map<String, dynamic> _convertMap(Map<dynamic, dynamic> map) {
  return map.map((key, value) => MapEntry(key.toString(), value));
}

Stream<DocumentSnapshot?> Shopping(String uid) {
  return FirebaseFirestore.instance
      .collection('Shopping_list')
      .doc(uid)
      .snapshots();
}