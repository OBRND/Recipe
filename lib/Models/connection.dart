import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:meal/Models/user_data.dart';

class ConnectivityNotifier with ChangeNotifier {
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  ConnectivityNotifier() {
    InternetConnection().onStatusChange.listen((status) {
      final connected = status == InternetStatus.connected;
      if (_isConnected != connected) {
        _isConnected = connected;
        notifyListeners();

        // Trigger synchronization when the device comes online
        if (_isConnected) {
          _synchronizeData();
        }
      }
    });
  }

  Future<void> _synchronizeData() async {
    final userBox = Hive.box('userData');
    final uid = 'user_uid'; // Replace with the actual user ID

    if (userBox.containsKey('userInfo')) {
      final hiveData = UserDataModel.fromMap(userBox.get('userInfo'), false);

      // Fetch Firebase data
      final snapshot = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      if (snapshot.exists) {
        final firebaseData = UserDataModel.fromMap(snapshot.data()!, true);

        // Compare timestamps to determine the most recent data
        if (firebaseData.lastUpdated.isAfter(hiveData.lastUpdated)) {
          // Firebase data is newer, update Hive
          await userBox.put('userInfo', firebaseData.toMap());
        } else if (firebaseData.lastUpdated.isBefore(hiveData.lastUpdated)) {
          // Hive data is newer, update Firebase
          await FirebaseFirestore.instance.collection('Users').doc(uid).update(hiveData.toMap());
        }
        // If timestamps are equal, no action is needed
      }
    }
  }
}


