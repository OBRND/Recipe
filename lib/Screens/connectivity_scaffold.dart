import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/connection.dart';

class ConnectivityAwareScaffold extends StatefulWidget {
  final Widget child;

  const ConnectivityAwareScaffold({Key? key, required this.child}) : super(key: key);

  @override
  State<ConnectivityAwareScaffold> createState() => _ConnectivityAwareScaffoldState();
}

class _ConnectivityAwareScaffoldState extends State<ConnectivityAwareScaffold> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final connectivityNotifier = Provider.of<ConnectivityNotifier>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final message = connectivityNotifier.isConnected
          ? 'Connected to the Internet'
          : 'No Internet Connection';

      final color = connectivityNotifier.isConnected ? Colors.green : Colors.red;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}