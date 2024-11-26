import 'package:flutter/material.dart';
import 'package:meal/Screens/recipe.dart';
import 'package:meal/Screens/home.dart';
import 'package:meal/Screens/shopping_list.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

class bottomNav extends StatefulWidget {
  const bottomNav({super.key});

  @override
  State<bottomNav> createState() => _bottomNavState();
}

class _bottomNavState extends State<bottomNav> {
  
  late PageController controller; 
  int selectedIndex = 1;

   void initState() {
    super.initState();
    controller = PageController(initialPage: selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
      physics: NeverScrollableScrollPhysics(),       
      controller: controller,
      children: _listOfWidget,
      ),
      bottomNavigationBar: SlidingClippedNavBar(
        backgroundColor: Colors.white,
        onButtonPressed: (index) {
          setState(() {
            selectedIndex = index;
          });
          controller.animateToPage(selectedIndex,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuad);
        },
        iconSize: 25,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        activeColor: Color(0xffa61208),
        inactiveColor: Colors.grey,
        selectedIndex: selectedIndex,
        barItems: [
          BarItem(
            icon: Icons.list,
            title: 'Shopping list',
          ),
          BarItem(
            icon: Icons.home_sharp,
            title: 'Home',
          ),
          BarItem(
            icon: Icons.dining_outlined,
            title: 'Recipes',
          ),
           /// Add more BarItem if you want
        ],
      ),
    );
  }
}

List<Widget> _listOfWidget = <Widget>[
  const ShoppingList(),
  const MyHomePage(),
  const Recipes(),
];