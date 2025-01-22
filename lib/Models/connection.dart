import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityNotifier with ChangeNotifier {
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  ConnectivityNotifier() {
    InternetConnection().onStatusChange.listen((status) {
      final connected = status == InternetStatus.connected;
      if (_isConnected != connected) {
        _isConnected = connected;
        notifyListeners();
      }
    });
  }
}
