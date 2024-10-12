import 'package:flutter/material.dart';

class Meals extends StatefulWidget {
  const Meals({super.key});

  @override
  State<Meals> createState() => _MealsState();
}

class _MealsState extends State<Meals> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipee Book"),
      ),
      body: const Text('Choose the meals that fits you'),
    );
  }
}
